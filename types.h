#ifndef TYPES_H
#define TYPES_H

#include <map>


//operator enum
enum {OPADD, OPSUB, OPMULT, OPDIV, OPMOD};

//comparator enum
enum {COMPEQ, COMPLT, COMPGT, COMPLTE, COMPGTE, COMPNEQ};

//Identifier Types
enum IDTYPE{IDFUNC, IDINT, IDARR};

//symbol types
enum SymbolType{SYM_INT, SYM_ARR};

map<string, SymbolType> symboltable;

class NonTerminal {
  public:
    string temp;
    NonTerminal();
    NonTerminal(string temp);
};

NonTerminal::NonTerminal(){
}

NonTerminal::NonTerminal(string temp){
  this->temp = temp;
}

/*
class Statement{
  public:
    string begin;
    string after;
    string code;
};
*/

//looks through symbol table for the corrosponding entry
//returns according to whether the entry was found or not
bool lookupSTE(string s){
  if(symboltable.find(s) != symboltable.end()) return true;
  else return false;
}

SymbolType getType(string symname){
  return symboltable[symname];
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
