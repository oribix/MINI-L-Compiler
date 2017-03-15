#ifndef TYPES_H
#define TYPES_H

#include <stack>

//operator enum
enum {OPADD, OPSUB, OPMULT, OPDIV, OPMOD};

//comparator enum
enum {COMPEQ, COMPLT, COMPGT, COMPLTE, COMPGTE, COMPNEQ};

//Identifier Types
enum IDTYPE{IDFUNC, IDINT, IDARR};

//symbol types
enum SymbolType{SYM_INT, SYM_ARR};

class Expression {
  public:
    string code;
    Expression * place;
    Expression();
    Expression(string code, Expression * place);
};

Expression::Expression(){
  place = NULL;
}

Expression::Expression(string code, Expression * place){
  this->place = place;
  this->code = code;
}

class Statement{
  public:
    string begin;
    string after;
    string code;
};

//Symbol table entry
class STE{
  public:
    string name;
    SymbolType type;
    int size;
    STE(string name, SymbolType type);
    STE(string name, SymbolType type, int size);
};

STE::STE(string name, SymbolType type){
  this->name = name;
  this->type = type;
  size = 0;
}

STE::STE(string name, SymbolType type, int size){
  this->name = name;
  this->type = type;
  this->size = size;
}

stack<STE> symbolTable;

//returns a new temporary each time
//returns a pointer to the Symbol Table Entry of a temp
//may take a parameter specifying the type of the temp
STE * newtemp(SymbolType type){
  static int tempnum;
  stringstream tempname;
  tempname << "TEMP" << tempnum++;
  STE entry = STE(tempname.str(), type);
  symbolTable.push(entry);
  return &symbolTable.top();
}

string newlabel(){
  static int labelnum;
  stringstream label;
  label << "LABEL" << labelnum++;
  return label.str();
}

#endif
