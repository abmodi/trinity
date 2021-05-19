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

    public abstract String simpleString();

    @Override
    public String toString() {
        StringBuilder builder = new StringBuilder();
        generateTreeString(0, builder);
        return builder.toString();
    }

    private void generateTreeString(int depth, StringBuilder builder) {
        for (int i = 0; i < depth; ++i) {
            builder.append("\t");
        }
        builder.append(simpleString());
        for(TreeNode child : children) {
            builder.append("\n");
            child.generateTreeString(depth+1, builder);
        }
    }
}