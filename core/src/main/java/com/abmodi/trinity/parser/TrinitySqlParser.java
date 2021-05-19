package com.abmodi.trinity.parser;

import com.abmodi.trinity.expression.*;
import com.abmodi.trinity.plans.logical.LogicalPlan;
import com.abmodi.trinity.plans.logical.OneRowRelation;
import com.abmodi.trinity.plans.logical.Project;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;

import java.util.Arrays;

public class TrinitySqlParser extends SqlBaseVisitor<Object> {
    public LogicalPlan parsePlan(String sqlText) {
        return visitSingleStatement(parse(sqlText).singleStatement());
    }

    public Expression parseExpression(String sqlText) {
        return visitSingleExpression(parse(sqlText).singleExpression());
    }

    @Override
    public Expression visitSingleExpression(SqlParser.SingleExpressionContext ctx) {
        return visitNamedExpression(ctx.namedExpression());
    }

    @Override
    public Attribute visitNamedExpression(SqlParser.NamedExpressionContext ctx) {
        Expression e = (Expression)visit(ctx.expression());
        if (ctx.identifier() != null) {
            return new Attribute(ctx.identifier().getText(), e);
        }
        return null;
    }

    @Override
    public Expression visitArithmeticBinary(SqlParser.ArithmeticBinaryContext ctx) {
        Expression left = (Expression) visit(ctx.left);
        Expression right = (Expression) visit(ctx.right);
        int type = ctx.operator.getType();

        if (type == SqlParser.ASTERISK) {
            return new Multiply(left, right);
        }
        else if (type == SqlParser.ADD) {
            return new Add(left, right);
        }

        return null;
    }

    @Override
    public LogicalPlan visitSingleStatement(SqlParser.SingleStatementContext ctx) {
        Object res = visit(ctx.statement());
        return (LogicalPlan)(res);
    }

    @Override
    public LogicalPlan visitQueryNoWith(SqlParser.QueryNoWithContext ctx) {
        return (LogicalPlan)(visit(ctx.queryTerm()));
    }

    @Override
    public LogicalPlan visitQuerySpecification(SqlParser.QuerySpecificationContext ctx) {
        OneRowRelation rel = new OneRowRelation();
        return withQuerySpecification(ctx, rel);
    }

    private LogicalPlan withQuerySpecification(SqlParser.QuerySpecificationContext ctx,
                                               LogicalPlan relation) {
        Attribute expr = visitNamedExpression(
                ctx.namedExpressionSeq().namedExpression().get(0));
        Project project = new Project(Arrays.asList(expr), relation);
        return project;
    }

    SqlParser parse(String command) {
        ANTLRInputStream inputStream = new ANTLRInputStream(command);
        SqlLexer lexer = new SqlLexer(inputStream);
        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        System.out.println("Token Stream: " + tokenStream);
        return new SqlParser(tokenStream);
    }
}
