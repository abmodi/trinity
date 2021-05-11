package com.abmodi.trinity;

public abstract class UnaryNode extends LogicalPlan {
    LogicalPlan child;

    public UnaryNode(LogicalPlan child) {
        this.child = child;
        addChild(child);
    }
}
