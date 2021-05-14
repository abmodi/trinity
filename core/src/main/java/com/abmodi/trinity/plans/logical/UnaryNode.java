package com.abmodi.trinity.plans.logical;

import com.abmodi.trinity.plans.logical.LogicalPlan;

public abstract class UnaryNode extends LogicalPlan {
    LogicalPlan child;

    public UnaryNode(LogicalPlan child) {
        this.child = child;
        addChild(child);
    }
}
