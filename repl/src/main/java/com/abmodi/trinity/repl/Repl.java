package com.abmodi.trinity.repl;

import com.abmodi.trinity.parser.TrinitySqlParser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class Repl {
    public static void main(String[] args) throws Exception {
        loop();
    }

    private static void loop() throws IOException {
        TrinitySqlParser parser = new TrinitySqlParser();
        BufferedReader reader = new BufferedReader(
                new InputStreamReader(System.in));
        while(true) {
            System.out.print("trinity>");
            String command = reader.readLine();
            if (command.equalsIgnoreCase("exit")) {
                System.exit(0);
            }
            System.out.println(parser.parsePlan(command));
            System.out.println(command);
        }
    }
}
