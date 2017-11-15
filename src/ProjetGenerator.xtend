/*
 * generated by Xtext 2.12.0
 */
package org.xtext.example.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.xtext.example.projet.FUNCTION
import org.xtext.example.projet.DEFINITION
import org.xtext.example.projet.INPUTS
import org.xtext.example.projet.COMMANDS
import org.xtext.example.projet.OUTPUTS
import org.xtext.example.projet.COMMAND
import org.xtext.example.projet.NOP
import org.xtext.example.projet.AFFECT
import org.xtext.example.projet.Domainmodel

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class ProjetGenerator extends AbstractGenerator {


	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {

		//Pour toutes les fonctions du fichier
		for(f: resource.allContents.toIterable.filter(typeof(FUNCTION))){
			//On g�n�re un fichier pour chaque fonction pr�sente dans le fichier
			fsa.generateFile(
				"components/" + f.name + ".whp",
				f.compile
			)
		}
		
		//Pour chaque fichier
		for(d: resource.allContents.toIterable.filter(typeof(Domainmodel))){
			//On g�n�re un nouveau fichier en appliquant la fonction compile sur tous les �l�ments du fichier
			fsa.generateFile(
				"file.whp",
				d.compile
			)
		}
	}
	
	//Pour le type "Domainmodel", qui repr�sente tout le fichier
	def compile(Domainmodel d) {
		//On compile toutes les fonctions comprises dans le fichier une � une
		'''
		�FOR f: d.functions�
			�f.compile�
			
		�ENDFOR�
		'''
	}
	
	//Pour le type "FUNCTION"
	def compile(FUNCTION f) {
		//On affiche le commentaire ";Result of pretty printing process function" 
		//et le nom de la fonction, puis on compile le contenu de la fonction
		'''
		; Result of pretty printing process
		function �f.name� :
		
			�f.def.compile�
		'''
		//f.def.compile est �crit apr�s une tabulation, ce qui va indenter tout le
		//contenu de la fonction
	}
	
	//Pour le type "DEFINTION"
	def compile(DEFINITION d) {
		//on affiche read input, puis le code int�rieur indent�, puis write output
		'''
		read �d.inputs.compile�
		%
			�d.code.compile�
		%
		write �d.outputs.compile�
		'''
	}
	
	//Pour le type INPUT
	def compile(INPUTS i) {
		//Rien de particulier pour l'instant
		'''
		�i.input�
		'''
	}
	
	//Pour le type OUTPUT
	def compile(OUTPUTS o) {
		//Rien de particulier pour l'instant
		'''
		�o.output�
		'''
	}
	
	//Pour le type "COMMANDS"
	def compile(COMMANDS c) {
		//Pour les commandes (IF/NOP/AFFECT/FOR/WHILE/EACH)
		'''
		�c.command.compile� �IF !c.commands.empty�;�ENDIF�
		�FOR line : c.commands�
			�line.compile� ;
		�ENDFOR�
		'''
	}
	
	//Pour le type "COMMAND", c�d chaque commande 
	def compile(COMMAND c) {
		'''COMMAND �c.eClass.name� TO DEVELOP HERE'''
	}
	
	//Pour le type "AFFECT"
	def compile(AFFECT a) {
		//TODO
		//La forme doit �tre variable := valeur
		'''AFFECTATION'''
	}
	
	//TODO
	//Fonctions compile pour : IF/NOP/FOR/WHILE/EACH/EXPRESSION/COMPARATOR/FOREACH/COMPARATOR/VAR
	
	
	

}
