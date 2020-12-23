#include <map>
#include <string>
#include <sstream>
#include <algorithm>
#include <iostream>
#include <vector>
#include <fstream>
#include <bitset>

const std::vector<std::string> OPCODES
{
	"nop",
		"ldw",
		"ldi",
		"stw",
		"add",
		"addu",
		"sub",
		"subu",
		"jmp",
		"ret",
		"beq",
		"bne",
		"mov",
		"psh",
		"pul",
		"and",
		"or",
		"not",
		"xor",
		"xnor",
		"sll",
		"srl",
		"mul",
		"div",
		"inl",
		"ini"
};

//Opcodes which does not have a register argument, but does have address argument
const std::vector<std::string> NOREGOPCODES
{
	"jmp",
		"beq",
		"bne",
		"inl",
		"ini"
};


const std::vector<std::string> REGISTERS
{
	"no",
		"ir",
		"iir",
		"xr",
		"yr",
		"sr",
		"mr"
};

//Labels need to be mapped to an address
std::map<std::string, int> LABELMAP;

//Meant for sorting words into keywords
enum TokenType{
	opcode,
	regArg,
	addrArg,
	constArg,
	labelArg,
	org,
	word,
	label,
	unknown};

void printVec(std::vector<std::string> v)
{
	std::cout << "1D VECTOR: \n";
	for(size_t i = 0; i < v.size(); i++)
	{
		std::cout << v.at(i) << "\n";
	}
}

void printVec(std::vector<std::bitset<8>> v)
{
	std::cout << "BINARY: \n";
	for(size_t i = 0; i < v.size(); i++)
	{
		std::cout << i << "\t| ";
		std::cout << v.at(i) << "\n";
	}
}

//Debugging purposes
std::string getEnumText(int i)
{
	std::string s;
	switch (i)
	{
		case opcode:
			s = "opcode";
			break;
		case regArg:
			s = "regArg";
			break;
		case addrArg:
			s = "addrArg";
			break;
		case constArg:
			s = "constArg";
			break;
			/* case charLiteralArg: */
			/* 	s = "charLiteralArg"; */
			/* 	break; */
		case labelArg:
			s = "labelArg";
			break;
		case org:
			s = "org";
			break;
		case word:
			s = "word";
			break;
		case label:
			s = "label";
			break;
		default:
			s = "UNKNOWN";
	}

	return s;
}

//Tokens, text, categorized by type, opcode, label, etc
struct Token
{
	std::string word;
	TokenType type;
};

//Renaming for simplicity
using TokenTable = std::vector<std::vector<Token>>;
using StringTable = std::vector<std::vector<std::string>>;

//Finding out which label is connected with a specific line, only for debugging
std::string getLabelFromLine(int val)
{
	std::string key = "none";
	for(auto& i : LABELMAP)
	{
		if(i.second == val)
		{
			key = i.first;
			break;
		}
	}
	return key;
}


void printVec(TokenTable v)
{
	std::cout << "TokenTable: size: " << v.size() << "\n";
	int lineNum = 0;
	for(auto& vec : v)
	{
		std::cout << lineNum << " | ";
		for(auto& token : vec)
		{
			std::cout << token.word << "(" << getEnumText(token.type) << ") ";
		}

		std::cout << "| label: " << getLabelFromLine(lineNum) << "\n";
		lineNum++;
	}
}


void printVec(StringTable v)
{
	std::cout << "2D VECTOR: \n";
	for(auto& vec : v)
	{
		for(auto& word : vec)
		{
			std::cout << word << " ";
		}
		std::cout << "| words: " << vec.size() << "\n";
	}
}

//Categorize all words into tokens
TokenTable buildTokens(StringTable st)
{
	TokenTable tt(st.size());
	std::vector<std::string> labels;
	//First runthrough
	for(size_t i = 0; i < st.size(); i++)
	{
		for(size_t j = 0; j < st.at(i).size(); j++)
		{
			Token t;
			t.word = st.at(i).at(j);
			if(t.word == ".word")
			{
				t.word = st.at(i).at(j+1);
				t.word.erase(std::remove(t.word.begin(), t.word.end(), '$'), t.word.end());
				t.type = word;
				j++;
			}
			else if(t.word == ".org")
			{
				t.word = st.at(i).at(j+1);
				t.type = org;
				t.word.erase(std::remove(t.word.begin(), t.word.end(), '$'), t.word.end());
				j++;
			}
			//Dollar means that its an addresss
			else if(t.word.find('$') != std::string::npos)
			{
				t.type = addrArg;
				t.word.erase(std::remove(t.word.begin(), t.word.end(), '$'), t.word.end());
			}
			//Hashtag means hex
			//There may of course exist others, which we find in the second runthrough
			else if(t.word.find('#') != std::string::npos)
			{
				t.type = constArg;
			}
			//Colon means label
			else if(t.word.find(':') != std::string::npos)
			{
				t.type = label;
				t.word.erase(std::remove(t.word.begin(), t.word.end(), ':'), t.word.end());
				//Needs to be pushed into label table as well
				if(std::find(labels.begin(), labels.end(), t.word) == labels.end())
				{
					labels.push_back(t.word);
				}

			}
			//Checking spesific lookuptables for register or opcode name
			else if(std::find(REGISTERS.begin(), REGISTERS.end(), t.word) != REGISTERS.end())
			{
				t.type = regArg;
			}
			else if(std::find(OPCODES.begin(), OPCODES.end(), t.word) != OPCODES.end())
			{
				t.type = opcode;
			}
			else
			{
				t.type = unknown;
			}

			tt.at(i).push_back(t);
		}
	}

	//Second runthrough
	//Checking whether the unknown tokens are in the dynamic label table
	//If not, we assume they are constant arguments
	for(auto& v : tt)
	{
		for(auto& t : v)
		{
			if(t.type == unknown)
			{

				if(std::find(labels.begin(), labels.end(), t.word) != labels.end())
				{
					t.type = labelArg;
				}
				else
				{
					t.type = constArg;
				}
			}

		}
	}
	return tt;

}



/* bool isSpace(unsigned char c) { */
/* 	return (c == ' ' || c == '\n' || c == '\r' || */
/* 			c == '\t' || c == '\v' || c == '\f'); */
/* } */

//Take the lines and separate them into words
std::vector<std::vector<std::string>> parseWords(std::vector<std::string> v)
{
	std::vector<std::vector<std::string>> words(v.size());

	for(size_t i = 0; i < v.size(); i++)
	{
		std::string word = "";
		for(char c : v.at(i))
		{
			if(c == ' ' || c == '\n' || c == '\r' || c == '\t')
			{
				if(word != "")
				{
					words.at(i).push_back(word);
					word = "";
				}
			}
			else
			{
				word += c;
			}

			if(c == ';')
			{
				word = "";
				break;
			}
		}
		if(word != "")
		{
			words.at(i).push_back(word);
			word = "";
		}

	}


	//Remove all empty vectors from table:
	for(int i = 0; i < words.size(); )
	{
		if(words.at(i).size() == 0)
			words.erase(words.begin() + i);
		else
		{
			i++;
		}
	}

	return words;

}

//Turn different sorts of numbers and characters into integer type
int numParser(std::string s)
{
	int x;
	std::stringstream ss;
	//Hex numbers:
	if(s.at(0) == '#')
	{
		s.erase(std::remove(s.begin(), s.end(), '#'), s.end());
		ss << std::hex;
	}
	//Character literals
	else if (s.at(0) == '\'')
	{
		s.erase(std::remove(s.begin(), s.end(), '\''), s.end());

		return int(s.at(0));
	}
	ss << s;
	ss >> x;
	std::cout << "X VALUE IS: " << x << ", when s is " << s << std::endl;

	return x;
}

//Place the instructions and words in the correct place in memory
TokenTable placeInRom(TokenTable old, int size)
{
	TokenTable tt(size);

	int index = 0;

	for(size_t i = 0; i < old.size(); i++)
	{
		switch(old.at(i).at(0).type)
		{
			case org:
				{
					std::cout << "ORG!!\n";
					index = numParser(old.at(i).at(0).word);
					std::cout << "changed index to " << index << "\n" << std::flush;
					break;
				}
			case word:
				{
					tt.at(index).push_back(old.at(i).at(0));
					index++;
					break;
				}
			case label:
				std::cout << "inserting " << old.at(i).at(0).word << " at index " << index << "\n";
				LABELMAP.insert(std::make_pair(old.at(i).at(0).word, index));
				/* index++; */
				break;
			case opcode:


				std::cout << "pushing back " << old.at(i).at(0).word << "\n";

				tt.at(index).push_back(old.at(i).at(0));

				if(old.at(i).size() > 1)
				{
					if(std::find(NOREGOPCODES.begin(), NOREGOPCODES.end(), (old.at(i).at(0).word)) != NOREGOPCODES.end())
					{
						std::cout << "INNE I NOREGOPCODES\n";
						tt.at(index + 1).push_back(old.at(i).at(1));
					}
					else
					{

						tt.at(index).push_back(old.at(i).at(1));
						if(old.at(i).size() > 2)
						{
							tt.at(index + 1).push_back(old.at(i).at(2));
							if(old.at(i).size() > 3)
							{
								tt.at(index + 1).push_back(old.at(i).at(3));
							}
						}
						else
						{
							Token t;
							t.word = "empty";
							t.type = unknown;
							tt.at(index + 1).push_back(t);
						}
					}
				}
				else
				{
					Token t;
					t.word = "empty";
					t.type = unknown;
					tt.at(index + 1).push_back(t);
				}
				index += 2;
				break;
			default:
				break;

				std::cout << std::flush;

		}
		std::cout << index << "\n";

	}


	return tt;
}

//Find opcode integer value from mnenomic
int getOpCodeVal(std::string code)
{
	int val;
	for(size_t i = 0; i < OPCODES.size(); i++)
	{
		if(OPCODES.at(i) == code)
		{
			val = i;
			break;
		}
	}
	return val;
}

//Find registercode from human readable name
int getRegisterVal(std::string code)
{
	int val;
	for(size_t i = 0; i < REGISTERS.size(); i++)
	{
		if(REGISTERS.at(i) == code)
		{
			val = i;
			break;
		}
	}
	return val;
}

//Concatenate two bitsets
template <size_t N1, size_t N2 >
std::bitset <N1 + N2> concatBitset( const std::bitset <N1> & b1, const std::bitset <N2> & b2 ) {
	std::string s1 = b1.to_string();
	std::string s2 = b2.to_string();
	return std::bitset <N1 + N2>( s1 + s2 );
}

//Turn TokenTable into binarylist
std::vector<std::bitset<8>> createBinaryVector(TokenTable tt)
{
	std::vector<std::bitset<8>> binary;
	int index = 0;
	for(auto& vec : tt)
	{
		if(vec.empty())
		{
			binary.push_back(std::bitset<8>(0));
			continue;
		}
		switch(vec.at(0).type)
		{
			case opcode:
				{
					std::bitset<5> a(getOpCodeVal(vec.at(0).word));
					std::bitset<3> b(0);
					if(vec.size() > 1)
					{
						b = (getRegisterVal(vec.at(1).word));
					}
					binary.push_back(concatBitset(a,b));
					break;
				}
			case addrArg:
				{

					std::bitset<8> a(numParser(vec.at(0).word));
					binary.push_back(a);
					break;
				}
			case labelArg:
				{
					std::bitset<8> a(LABELMAP.at(vec.at(0).word));
					binary.push_back(a);
					break;
				}
			case constArg:
				{
					std::bitset<8> a(numParser(vec.at(0).word));
					binary.push_back(a);
					break;
				}
			case regArg:
				{
					std::bitset<8> a(getRegisterVal(vec.at(0).word));
					binary.push_back(a);
					break;
				}
			case word:
				{
					std::bitset<8> a(numParser(vec.at(0).word));
					binary.push_back(a);
					break;
				}
			default:
				binary.push_back(std::bitset<8>(0));
				break;

		}

		index++;
	}



	return binary;

}

void writeToFile(std::vector<std::bitset<8>> binary, std::string fileName)
{

	std::ofstream file(fileName);
	if(file.is_open())
	{
		for(auto& b : binary)
		{
			file << b.to_string() << "\n";
		}
	}
}

void printLabelMap()
{
	std::cout << "Labelmap:\n";
	for(auto& i : LABELMAP)
	{
		std::cout << i.first << ", " << i.second << "\n";
	}
}

int main(int argc, char* argv[])
{
	if(argc != 3)
	{
		std::cout << "Error in parsing arguments";
		return -1;
	}
	std::ifstream infile(argv[1]);
	int size = atoi(argv[2]);
	std::string line;
	std::vector<std::string> lines;

	while(std::getline(infile, line))
	{
		lines.push_back(line);
	}


	/* printVec(lines); */
	auto wordVector = parseWords(lines);
	/* printVec(wordVector); */
	auto tt = buildTokens(wordVector);
	printVec(tt);


	auto lineTokens = placeInRom(tt, size);
	std::cout << "\n\n";
	printVec(lineTokens);
	std::cout << "Starting binaryVector\n" << std::flush;

	auto binary = createBinaryVector(lineTokens);

	printVec(binary);

	printLabelMap();
	writeToFile(binary, "../prog.bin");


	return 0;
}
