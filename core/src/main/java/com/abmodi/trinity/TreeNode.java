package com.abmodi.trinity;

import java.util.ArrayList;
import java.util.List;

public abstract class TreeNode<T> {
    final private List<TreeNode<T>> children;

    public TreeNode() {
        children = new ArrayList<>();
    }

    public List<TreeNode<T>> getChildren() {
        return children;
    }

    public void addChild(TreeNode<T> node) {
        children.add(node);
    }
}