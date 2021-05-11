package com.abmodi.trinity;

public class Project extends UnaryNode {
    String projectList;

    Project(String projectList, LogicalPlan child) {
        super(child);
        this.projectList = projectList;
    }
}
