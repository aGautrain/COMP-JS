package org.xtext.example.generator;

import java.util.ArrayList;

public class While extends Instruction{
	private String left;
	private ArrayList<Instruction> right;
	
	public While(String condition){
		this.left = condition;
		this.right = new ArrayList<Instruction>();
	}
	
	public void setRes(String res){
		this.res = res;
	}
	
	public void setLeft(String left){
		this.left = left;
	}
	
	public ArrayList<Instruction> getCode(){
		return this.right;
	}

	public String toString(){
		String ret = "<WHILE, "+this.res+", "+left+", [";
		for(Instruction instr : right){
			ret+=instr.toString()+",";
		}
		ret+="]>";
		return ret;
	}
	
	public String getLeft() {
		return left;
	}
}
