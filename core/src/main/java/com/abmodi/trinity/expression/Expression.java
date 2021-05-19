package com.abmodi.trinity.expression;

import com.abmodi.trinity.TreeNode;

public abstract class Expression extends TreeNode<Expression> {
    public abstract int eval();

    public String simpleString() {
        return "Expression";
    }
}
