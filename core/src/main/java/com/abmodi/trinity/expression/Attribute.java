package com.abmodi.trinity.expression;

import com.abmodi.trinity.expression.Expression;

public class Attribute extends Expression {
    String name;
    Expression child;

    public Attribute(String name, Expression child) {
        this.name = name;
        this.child = child;
        this.addChild(child);
    }

    @Override
    public int eval() {
        return child.eval();
    }
}
