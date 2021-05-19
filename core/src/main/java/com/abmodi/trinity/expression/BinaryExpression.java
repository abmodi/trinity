package com.abmodi.trinity.expression;

public abstract class BinaryExpression extends Expression {
    Expression left;
    Expression right;

    public BinaryExpression(Expression left, Expression right) {
        this.addChild(left);
        this.addChild(right);
        this.left = left;
        this.right = right;
    }
}
