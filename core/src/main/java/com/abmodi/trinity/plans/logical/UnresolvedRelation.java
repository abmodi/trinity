package com.abmodi.trinity.plans.logical;

import com.abmodi.trinity.plans.logical.LeafNode;

public class UnresolvedRelation extends LeafNode {
    String tableName;
    UnresolvedRelation(String tableName) {
        this.tableName = tableName;
    }

    @Override
    public String simpleString() {
        return "UnresolvedRelation";
    }
}
