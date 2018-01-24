package org.xtext.example.generator;

import java.util.ArrayList;

public class If extends Instruction{
	private String left;
	private ArrayList<Instruction> right, rightBis;
	
	public If(String condition){
		this.left = condition;
		this.right = new ArrayList<Instruction>();
		this.rightBis = new ArrayList<Instruction>();
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
	
	public ArrayList<Instruction> getCodeBis(){
		return this.rightBis;
	}

	public String toString(){
		String ret = "<IF, "+this.res+", "+left+", [";
		for(Instruction instr : right){
			ret+=instr.toString()+",";
		}
		ret+="], [";
		for(Instruction instr : rightBis){
			ret+=instr.toString()+",";
		}
		ret+= "]>";
		return ret;
	}
}
