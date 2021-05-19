package com.abmodi.trinity.plans.logical;

import com.abmodi.trinity.expression.Attribute;

import java.util.List;

public class Project extends UnaryNode {
    List<Attribute> projectList;

    public Project(List<Attribute> projectList, LogicalPlan child) {
        super(child);
        this.projectList = projectList;
    }

    @Override
    public String simpleString() {
        return "Project";
    }
}
