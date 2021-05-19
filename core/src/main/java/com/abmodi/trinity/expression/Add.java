package com.abmodi.trinity.expression;

public class Add extends BinaryExpression {
    public Add(Expression left, Expression right) {
        super(left, right);
    }

    @Override
    public int eval() {
        return left.eval() + right.eval();
    }
}
