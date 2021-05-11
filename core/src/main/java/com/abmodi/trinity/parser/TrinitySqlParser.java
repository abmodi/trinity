package com.abmodi.trinity.parser;

import com.abmodi.trinity.Attribute;
import com.abmodi.trinity.Expression;
import com.abmodi.trinity.LogicalPlan;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;

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
    public Expression visitNamedExpression(SqlParser.NamedExpressionContext ctx) {
        return new Attribute(ctx.getText());
    }

    @Override
    public LogicalPlan visitSingleStatement(SqlParser.SingleStatementContext ctx) {
        return null;
    }

    SqlParser parse(String command) {
        ANTLRInputStream inputStream = new ANTLRInputStream(command);
        SqlLexer lexer = new SqlLexer(inputStream);
        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        System.out.println("Token Stream: " + tokenStream);
        SqlParser parser = new SqlParser(tokenStream);
        return parser;
    }
}
