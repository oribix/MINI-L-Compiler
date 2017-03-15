#ifndef TYPES_H
#define TYPES_H

class Expression_t {
  public:
    string code;
    Expression_t * place;
    Expression_t();
    Expression_t(string code, Expression_t * place);
};

Expression_t::Expression_t(){
  place = NULL;
}

Expression_t::Expression_t(string code, Expression_t * place){
  this->place = place;
  this->code = code;
}

class Statement_t{
  public:
    string begin;
    string after;
    string code;
};

Expression_t * newtemp(){
  return new Expression_t();
}

string newlabel(){
  static int labelnum;
  stringstream label;
  label << "LABEL" << labelnum++;
  return label.str();
}

#endif
