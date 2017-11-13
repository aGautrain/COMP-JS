/*
 * generated by Xtext 2.12.0
 */
package org.xtext.example.generator;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Provider;
import java.util.List;


import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.generator.GeneratorContext;
import org.eclipse.xtext.generator.GeneratorDelegate;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;
import org.xtext.example.ProjetStandaloneSetupGenerated;

public class Main {

	public static void main(String[] args) {
		if (args.length == 0) {
			System.err.println("Aborting: no path to EMF resource provided!");
			return;
		}
		Injector injector = new ProjetStandaloneSetupGenerated().createInjectorAndDoEMFRegistration();
		Main main = injector.getInstance(Main.class);
		main.runGenerator(args[0]);
	}

	@Inject
	private Provider<ResourceSet> resourceSetProvider;

	@Inject
	private IResourceValidator validator;

	@Inject
	private GeneratorDelegate generator;

	@Inject 
	private JavaIoFileSystemAccess fileAccess;

	protected void runGenerator(String string) {
		// Load the resource
		ResourceSet set = resourceSetProvider.get();
		Resource resource = set.getResource(URI.createFileURI(string), true);

		
		// TEST 1 : Visiting the content as a tree structure
		System.out.println("TREE MODE");
		TreeIterator<EObject> tree = resource.getAllContents();
		EObject currentNode = null;
		while((currentNode = tree.next()) != null){
			System.out.println(currentNode.toString());
			
			System.out.println(currentNode.eClass().getName());
			// System.out.println(currentNode.eGet(currentNode.eContainingFeature()));
			
			if(!tree.hasNext()) break;
		}
		
		System.out.println("VALIDATION STARTS ..");
		
		
		// TEST 2 : Visiting the content through 2 for each imbricated
		/*
		System.out.println("LIST MODE");
		EObject root = resource.getContents().get(0);

		System.out.println(root.getClass().getSimpleName());
		EList<EObject> subcontent = root.eContents();
		for (EObject subo : subcontent) {
			System.out.println("\t" + subo.getClass().getSimpleName());
		}
		*/
		
		// Validate the resource
		List<Issue> list = validator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl);
		if (!list.isEmpty()) {
			for (Issue issue : list) {
				System.err.println(issue);
			}
			return;
		}

		
		
		// Configure and start the generator
		fileAccess.setOutputPath("src-gen/");
		GeneratorContext context = new GeneratorContext();
		context.setCancelIndicator(CancelIndicator.NullImpl);
		generator.generate(resource, fileAccess, context);

		System.out.println("Code generation finished.");
	}
}