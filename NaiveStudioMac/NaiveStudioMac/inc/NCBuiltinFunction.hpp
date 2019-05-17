//
//  NCBuiltinFunction.hpp
//  NaiveC
//
//  Created by 梁志远 on 28/08/2017.
//  Copyright © 2017 Ogreaxe. All rights reserved.
//

#ifndef NCBuiltinFunction_hpp
#define NCBuiltinFunction_hpp

#include <stdio.h>
#include "NCAST.hpp"
#include "NCStackElement.hpp"

class NCBuiltinFunction{
public:
    NCBuiltinFunction():hasReturn(false){}
    virtual ~NCBuiltinFunction(){}
    
    bool hasReturn;
    string name;
    vector<shared_ptr<NCParameter>> parameters; //formal parameters
    
    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments,vector<shared_ptr<NCStackElement>> & lastStack)=0;
    
    //if has no return
    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments)=0;
};

class NCBuiltinPrint:public NCBuiltinFunction{
public:
    NCBuiltinPrint();
    
    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments,vector<shared_ptr<NCStackElement>> & lastStack);
    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments);
};

class NCBuiltinGetObject:public NCBuiltinFunction{
public:
    NCBuiltinGetObject();
    
    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments,vector<shared_ptr<NCStackElement>> & lastStack);
    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments);
};

class NCBuiltinQueryView:public NCBuiltinFunction{
public:
    NCBuiltinQueryView();
    
    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments,vector<shared_ptr<NCStackElement>> & lastStack);
    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments);
};

//class NCBuiltinGetAdaptorValue :public NCBuiltinFunction{
//public:
//    NCBuiltinGetAdaptorValue();
//    
//    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments,vector<shared_ptr<NCStackElement>> & lastStack);
//    virtual bool invoke(vector<shared_ptr<NCStackElement>> &arguments);
//};

#endif /* NCBuiltinFunction_hpp */
