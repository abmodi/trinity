package com.abmodi.trinity.expression;

import com.abmodi.trinity.expression.Expression;

public class Attribute extends Expression {
    String name;

    public Attribute(String name, Expression child) {
        this.name = name;
        this.addChild(child);
    }
}
