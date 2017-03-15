#ifndef TYPES_H
#define TYPES_H

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

Expression * newtemp(){
  return new Expression();
}

string newlabel(){
  static int labelnum;
  stringstream label;
  label << "LABEL" << labelnum++;
  return label.str();
}

#endif
