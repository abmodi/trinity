package com.abmodi.trinity;

public class UnresolvedRelation extends LeafNode {
    String tableName;
    UnresolvedRelation(String tableName) {
        this.tableName = tableName;
    }
}
