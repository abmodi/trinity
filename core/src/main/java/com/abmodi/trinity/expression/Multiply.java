package com.abmodi.trinity.expression;

public class Multiply extends BinaryExpression {
    public Multiply(Expression left, Expression right) {
        super(left, right);
    }

    @Override
    public int eval() {
        return left.eval() * right.eval();
    }
}
