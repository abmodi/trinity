package com.abmodi.trinity.expression;

import com.abmodi.trinity.expression.Expression;

public class Literal extends Expression {
    int value;

    public Literal(int val) {
        value = val;
    }

    @Override
    public int eval() {
        return value;
    }
}
