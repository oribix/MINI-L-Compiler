#ifndef TYPES_H
#define TYPES_H

#include <map>
#include <list>

//Identifier Types
enum IDTYPE{IDFUNC, IDINT, IDARR};

//symbol types
enum SymbolType{SYM_INT, SYM_ARR};

map<string, SymbolType> symboltable;

class NonTerminal {
  public:
    string temp;
    string code;
    NonTerminal();
    NonTerminal(string temp);
};

NonTerminal::NonTerminal(){
}

NonTerminal::NonTerminal(string temp){
  this->temp = temp;
}

class Variable : public NonTerminal{
  public:
    string index;
    Variable();
};

Variable::Variable(){}

//wrapper for union
class NTList{
  public:
    list<NonTerminal> ntlist;
};

class VList{
  public:
    list<Variable> vlist;
};

class Declaration : public NonTerminal{
  public:
    list<string> identifiers;
};

class DList{
  public:
    list<Declaration> dlist;
};

//looks through symbol table for the corrosponding entry
//returns according to whether the entry was found or not
bool lookupSTE(string s){
  if(symboltable.find(s) != symboltable.end()) return true;
  else return false;
}

//gets type of symbol from symbol table
SymbolType getType(string symname){
  return symboltable[symname];
}

//add symbol with type to symbol table
void addToSymbolTable(string name, SymbolType type){
  symboltable[name] = type;
}

//returns a new temporary each time
//returns a pointer to the Symbol Table Entry of a temp
//may take a parameter specifying the type of the temp
string newtemp(SymbolType type){
  static int tempnum;
  stringstream tempname;
  tempname << "TEMP" << tempnum++;
  string tempstring = tempname.str();
  symboltable[tempstring] = type;
  return tempstring;
}

string newlabel(){
  static int labelnum;
  stringstream label;
  label << "LABEL" << labelnum++;
  return label.str();
}

#endif
