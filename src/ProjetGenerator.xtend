/*
 * generated by Xtext 2.12.0
 */
package org.xtext.example.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.xtext.example.projet.AFFECT
import org.xtext.example.projet.COMMAND
import org.xtext.example.projet.COMMANDS
import org.xtext.example.projet.DEFINITION
import org.xtext.example.projet.EXPRESSION
import org.xtext.example.projet.FOREACH
import org.xtext.example.projet.FOR_LOOP
import org.xtext.example.projet.FUNCTION
import org.xtext.example.projet.IF_THEN
import org.xtext.example.projet.INPUTS
import org.xtext.example.projet.NOP
import org.xtext.example.projet.OUTPUTS
import org.xtext.example.projet.PROGRAM
import org.xtext.example.projet.WHILE
import org.xtext.example.projet.EXPRAND
import org.xtext.example.projet.EXPROR
import org.xtext.example.projet.EXPRNOT
import org.xtext.example.projet.EXPREQ
import org.xtext.example.projet.EXPRSIMPLE
import org.xtext.example.projet.LEXPR

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class ProjetGenerator extends AbstractGenerator {
	
	//table des fonctions
	static private funcTab table
	//num�ro de fonction
	int num
	//funcEntry utilis� pour ajouter des fonctions � la funcTab
	funcEntry nouvelleFunc
	
	code3A newCode
		
	String res
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		this.table = new funcTab();
		num=0;
		// Pour toutes les fonctions du fichier
		/*for (f : resource.allContents.toIterable.filter(typeof(FUNCTION))) {
			// On g�n�re un fichier pour chaque fonction pr�sente dans le fichier
			fsa.generateFile(
				"components/" + f.name + ".whp",
				f.compile	
			)
		}*/

		// Pour chaque fichier
		for (d : resource.allContents.toIterable.filter(typeof(PROGRAM))) {
			// On g�n�re un nouveau fichier en appliquant la fonction compile sur tous les �l�ments du fichier
			fsa.generateFile(
				"file.whp",
				d.compile
			)
		}
		println(table.toString());
	}

	// Pour le type "PROGRAM", qui repr�sente tout le programme
	def compile(PROGRAM d) {
		// On compile toutes les fonctions comprises dans le fichier une � une
		'''
			�FOR f : d.functions�
				�f.compile�
			�ENDFOR�
		'''
	}

	// Pour le type "FUNCTION"
	def compile(FUNCTION f) {
		// On affiche le nom de la fonction, puis on compile le contenu de la fonction
		'''
			function �f.name�:
				�f.def.compile�
		'''
	// f.def.compile est �crit apr�s une tabulation, ce qui va indenter tout le
	// contenu de la fonction
	}

	// Pour le type "DEFINTION"
	def compile(DEFINITION d) {
		// on affiche read input, puis le code int�rieur indent�, puis write output
		nouvelleFunc = new funcEntry()
		table.addFunc("f"+num,nouvelleFunc)
		num++
		'''
			read �d.inputs.compile�
			%
				�d.code.compile�
			%
			write �d.outputs.compile�
		'''
	}

	// Pour le type INPUT
	def compile(INPUTS i) {
		nouvelleFunc.addIn()
		nouvelleFunc.addVar(i.input)
		// On affiche tous les inputs, s�par�s par des virgules		
		'''�i.input��FOR x : i.inputs�, �x.compile��ENDFOR�'''
		
	}

	// Pour le type OUTPUT
	def compile(OUTPUTS o) {
		nouvelleFunc.addOut();
		//On affiche tous les outputs, s�par�s par des virgules
		'''�o.output��FOR x : o.outputs�, �x.compile��ENDFOR�'''
	}

	// Pour le type "COMMANDS"
	def compile(COMMANDS c) {
		// Pour les commandes (IF/NOP/AFFECT/FOR/WHILE/EACH)
		'''
			�c.command.compile��IF !c.commands.empty� ;�ENDIF�
			�FOR line : c.commands�
				�line.compile��IF line != c.commands.last� ;�ENDIF�
			�ENDFOR�
		'''
	}

	// Pour le type "COMMAND", c�d chaque commande 
	def compile(COMMAND c) {
		// Pour chaque commande, on caste dans le subtype pour le compiler
		if(c.eClass.name == "AFFECT"){
			return '''�(c as AFFECT).compile(nouvelleFunc.addCode("_","_","_","_"))�'''
		}
		if(c.eClass.name == "IF_THEN"){
			return '''�(c as IF_THEN).compile(nouvelleFunc.addCode("if","_","_","_"))�'''
		}
		if(c.eClass.name == "NOP"){
			return '''�(c as NOP).compile(nouvelleFunc.addCode("nop","_","_","_"))�'''
		}
		if(c.eClass.name == "FOR_LOOP"){
			return '''�(c as FOR_LOOP).compile(nouvelleFunc.addCode("for","_","_","_"))�'''
		}
		if(c.eClass.name == "WHILE"){
			return '''�(c as WHILE).compile(nouvelleFunc.addCode("while","_","_","_"))�'''
		}
		if(c.eClass.name == "FOREACH"){
			return '''�(c as FOREACH).compile(nouvelleFunc.addCode("foreach","_","_","_"))�'''
		}
	}

	// Pour le type "AFFECT"
	def compile(AFFECT a, code3A code) {
		nouvelleFunc.addVar(a.variable)
		code.setRes(a.variable)
		//On �crit toutes les variables de gauche s�par�es par ", " puis " := ", puis tutes les variables de droites s�par�es par ", "
		'''�a.variable��FOR x : a.vars�, �x��nouvelleFunc.addVar(x)��ENDFOR� := �a.valeur.compile(code)��FOR y : a.vals�, �y.compile(code)��ENDFOR�'''
	}

	// Pour le type "IF_THEN"
	def compile(IF_THEN if_then, code3A code) {
		res='''
			if �code.setLeft(if_then.cond.compile(code).toString)��if_then.cond.compile(code)� then
				�FOR line : if_then.commands1�
					�line.compile�
				�ENDFOR�
			'''	
		if (!if_then.commands2.empty){
			nouvelleFunc.addCode("else","_","_","_")
			res+='''
			else
				�FOR line : if_then.commands2�
					�line.compile�
				�ENDFOR�
			'''
		}
		res+='''
			fi'''
		nouvelleFunc.addCode("fi","_","_","_")
		return res
	}

	// Pour le type "NOP"
	def compile(NOP n, code3A code) {
		'''nop'''
	}
	
	//Pour le type "FOR_LOOP"
	def compile(FOR_LOOP fl, code3A code){
		res='''
			for �code.setLeft(fl.exp.compile(code).toString)��fl.exp.compile(code)� do
				�FOR line : fl.commands�
					�line.compile�
				�ENDFOR�
			od'''
		nouvelleFunc.addCode("od","_","_","_")
		return res
	}
	
	//Pour le type "WHILE"
	def compile(WHILE w, code3A code){
		res='''
			while �code.setLeft(w.cond.compile(code).toString)��w.cond.compile(code)� do
				�FOR line : w.commands�
					�line.compile�
				�ENDFOR�
			od'''
		nouvelleFunc.addCode("od","_","_","_")
		return res
	}
	
	//Pour le type "FOREACH"
	def compile(FOREACH fe, code3A code){
		res='''
			foreach �code.setLeft(fe.exp1.compile(code).toString)��fe.exp1.compile(code)� in �fe.exp2.compile(code)� do
				�FOR line : fe.commands�
					�line.compile�
				�ENDFOR�
			od'''	
		nouvelleFunc.addCode("od","_","_","_")
		return res
  	}


	//Pour le type "EXPRESSION"
	def compile(EXPRESSION e, code3A code){
		'''�e.expand.compile(code)�'''
	}
	
	def compile(EXPRAND e, code3A code){
		if (!e.expors.empty){
			code.setOp("and")
			'''�code.setLeft(e.expor.compile(code).toString)��e.expor.compile(code)� and �FOR line:e.expors��code.setRight(line.compile(code).toString)��line.compile(code)��ENDFOR�'''
		}else{
			'''�e.expor.compile(code)�'''
		}
	}
	
	def compile(EXPROR e, code3A code){
		if (!e.expnots.empty){
			code.setOp("or")
			'''�code.setLeft(e.expnot.compile(code).toString)��e.expnot.compile(code)� or �FOR line:e.expnots��code.setRight(line.compile(code).toString)��line.compile(code)��ENDFOR�'''
		}else{
			'''�e.expnot.compile(code)�'''
		}
	}
	
	def compile(EXPRNOT e, code3A code){
		if(e.n !== null){
			nouvelleFunc.addCode("not","_",e.expeq.compile(code).toString,"_")
			'''not �e.expeq.compile(code)�'''
		}else{
			'''�e.expeq.compile(code)�'''
		}
	}
	
	def compile(EXPREQ e, code3A code){
		if(e.exp1 !== null){
			if(!e.exp2.empty){
				code.setOp("=?")
				'''�code.setLeft(e.exp1.compile(code).toString)��e.exp1.compile(code)� =? �FOR line:e.exp2��code.setRight(line.compile(code).toString)��line.compile(code)��ENDFOR�'''
			}else{
				'''�e.exp1.compile(code)�'''
			}
		}else{
			'''(�e.exp.compile(code)�)'''
		}
	}
	
	def compile(EXPRSIMPLE e, code3A code){
		if(e.valeur !== null){
			if(e.valeur.toString == "nil"){
				code.setOp("nil")
			}else{
				if (code.getOp == "_"){
					code.setOp("const "+e.valeur.toString)
				}
			}
			return e.valeur.toString
		}else if(e.cons !== null){
			//to do
			return '''(cons �e.lexpr.compile(code)�)'''
		}else if(e.list !== null){
			//to do
			return '''(list �e.lexpr.compile(code)�)'''
		}else if(e.hd !== null){
			res = e.expr.compile(code).toString
			code.setOp("hd " + res)
			return '''(hd �res�)'''
		}else if(e.tl !== null){
			res = e.expr.compile(code).toString
			code.setOp("tl "+res)
			return '''(tl �res�)'''
		}else if(e.sym !== null){
			//to do
			return '''(�e.sym.toString� �e.lexpr.compile(code)�)'''
		}
	}
	
	def compile(LEXPR e, code3A code){
		//to do
		'''�e.expr.compile(code)��IF e.lexpr !== null��e.lexpr.compile(code)��ENDIF�'''
	}

}
