package com.abmodi.trinity.parser;

import com.abmodi.trinity.expression.Attribute;
import com.abmodi.trinity.expression.Expression;
import com.abmodi.trinity.expression.Literal;
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
    public Expression visitIntegerLiteral(SqlParser.IntegerLiteralContext ctx) {
        return new Literal(Integer.parseInt(ctx.getText()));
    }

    @Override
    public LogicalPlan visitSingleStatement(SqlParser.SingleStatementContext ctx) {
        return (LogicalPlan)visit(ctx.statement());
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
