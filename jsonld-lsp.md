---
title: "Bringing IDE Support to JSON-LD with the Language Server Protocol"
date: \today
author:
- name: Arthur Vercruysse
  institute: Ghent University
- name: Pieter Colpaert
  institute: Ghent University
institute: "Ghent University"
bibliography: "bibliography.bib"
link-citations: true
urlcolor: "blue"
keywords: "Linked Data, JSON-LD, Language Server"
abstract: |
  JSON-LD is a popular data format used to describe and share structured data on the web. However, creating and editing JSON-LD documents can be a challenging task, especially when dealing with complex contexts and many properties. In this paper, we introduce a JSON-LD Language Server Protocol (LSP) that provides code completion and renaming capabilities based on the defined terms inside the context.
  Our JSON-LD LSP can be used in any development environment that supports LSPs, such as Visual Studio Code or NeoVim. With our LSP, developers can easily use terms and properties defined in the JSON-LD context by providing auto-completion. Moreover, our LSP allows the user to rename objects inside the JSON-LD document.
  While our current implementation focuses on code completion and renaming, there is still much more that can be added to the JSON-LD LSP. For example, hover, go-to-definition and code actions like flattening or structuring of JSON-LD documents are possible features for future enhancements.
---

# Introduction

JSON-LD is a data serialization format that is used to describe semi-structured data on the web [@JSON-LD-W3C]. While it is not a programming language in the traditional sense, it is often used to represent complex data structures. This means that developers who work with JSON-LD may benefit from some of the same tools and features that are commonly used in programming languages.

To provide a similar level of IDE support for JSON-LD as for programming languages, we can look at what brings these capabilities to IDEs. One of the key technologies used in modern IDEs is the language server protocol (LSP)[@LSP-editor]. The LSP is a standard interface for implementing language-specific features, such as code completion, hover information, and go-to-definition. By implementing an LSP for JSON-LD, developers can benefit from some IDE capabilities [@LSP-Multi].

<!-- What is the competition doing? JSON with JSON schema? Autocompletion with Yasgui? Turtle lsp (stardog) -->
Similar efforts have been made before, but never for JSON-LD. For example, the Yasgui editor [@YASGUI], a popular SPARQL human query interface, provides autocompletion based on the LOV API [@LOV]. Users can also provide a plugin to add autocompletion based on domain knowledge. Stardog provides open-source LSPs for turtle, TRIG, SPARQL and more. These servers however only concern themselves with correct syntax and keyword auto-completion [@stardog].

## JSON-LD

JSON-LD is a linked data format that uses the same syntax as JSON [@JSON-LD-W3C]. JSON-LD gives special meaning to certain fields, like `\@id` and `\@type`. `\@id` denotes the identifier of the current object, and can be used to refer to other objects in that document or on the web. RDF can be extracted from a JSON-LD document by interpreting all fields as predicates and all values as objects for some subject, denoted by `\@id` or a blank node if `\@id` is absent.

A JSON-LD context is used to define the meaning of terms and properties used in a document, in contrast with JSON schema, which defines and validates a structure [@JSON-LD-modeling]. The context provides a way to map short-hand terms to their full definitions and to specify the data types, language, and other information about the properties used in the document. For example, the following JSON-LD document contains a context that defines the term `name` and maps it to the full IRI `http://schema.org/name` and maps `knows` to `http://xmlns.com/foaf/0.1/knows` but also makes it clear the expected value is another object or the identifier of another object. The document specifies that someone with the name "Arthur" knows IRI "https://pietercolpaert.be/#me".

```json
{
  "@context": {
    "name": "http://schema.org/name",
    "knows": {
      "@id": "http://xmlns.com/foaf/0.1/knows",
      "@type": "@id"
    }
  },
  "name": "Arthur",
  "knows": {" @id": "https://pietercolpaert.be/#me" }
}
```

JSON-LD context can provide a lot more information, but this will only be touched upon in the discussion section.

<!--  Compoare jsonld with a programming language, see what is required/expected -->
  <!-- OSLO maakt het echt nodig om zo een extentie te hebben https://www.vlaanderen.be/digitaal-vlaanderen/onze-oplossingen/oslo -->
As the use of JSON-LD grows in the semantic web community, IDE support for it becomes increasingly essential. Major players in this field are publishing open standards and application profiles by exposing JSON-LD contexts. For example, OSLO is a Flemish initiative that is working to achieve interoperability across Flanders by building semantic standards for different stakeholders such as government, industry and academia [@OSLO]. Thus, making it easier to exchange data. This effort starts by using the same JSON-LD context, which highlights the importance of IDE support for JSON-LD.

## Language Server Protocol  

The Language Server Protocol (LSP) is a JSON RPC protocol developed by Microsoft to simplify the process of integrating language-specific logic into an editor. Prior to LSP, editors had to implement each programming language they wanted to support individually, resulting in an $O(n*m)$ complexity where n is the number of editors and m is the number of programming languages. With LSP, editor and language-specific logic only needs to be implemented once, resulting in a much simpler $O(n+m)$ complexity.

LSP only concerns itself with the source files of the program and doesn't involve building, running, or debugging. This is in contrast to the Build Server Protocol [@Builder-Server]. To implement an LSP, you can support predefined functions like auto complete, go to definition, find all references etc. Not everything needs to be implemented, as the editor and server can negotiate capabilities.

Overall, the Language Server Protocol has greatly simplified the process of integrating language-specific logic into an editor. LSP has made it easier for developers to work with a wide range of programming languages and editors. Currently, there are 130 LSP servers for over 99 different programming languages. JSON-LD can be the 100th language to benefit from LSP.

<!-- Explaing our solution: LSP (editor independant etc) -->
  <!-- LSP brings IDE capabilities to any editor (such as hover, auto completion, goto defintition, code actions etc) -->
  <!-- LSP is a json RPC specification -->
  <!-- There were other options, like build server protocol, but these were not required and less available OR SLSP (the Specification Language Server Protocol: Unifying LSP Extensions) --> 


# Demo



## Future work

 
 
