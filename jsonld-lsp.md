---
title: "Bringing IDE Support to JSON-LD with the Language Server Protocol"
date: \today
author:
- name: Arthur Vercruysse
  institute: Ghent University
- name: Julian Rojas
  institute: Ghent University
- name: Pieter Colpaert
  institute: Ghent University
institute: "IDLab, Department of Electronics and Information Systems, Ghent University – imec"
bibliography: "bibliography.bib"
link-citations: true
urlcolor: "blue"
keywords: "Linked Data, JSON-LD, Language Server"
abstract: |
  JSON-LD is a popular data format used to describe and share semantic data on the web.
  However, creating and editing JSON-LD documents can be a challenging task, especially when dealing with complex contexts, including many properties. The existing JSON editing functionality may not suffice for developers, and a JSON-LD editor could greatly enhance their experience.
  In this paper, we introduce a JSON-LD Language Server Protocol (LSP) that enables text editors compatible with the LSP protocol (e.g., Visual Studio Code and NeoVim), to suggest autocompletion items based on the defined context, and it also enables renaming identifiers inside the document.
  We believe that the implementation of our LSP will enhance developer ergonomics and promote the adoption of JSON-LD. Moreover, we see high potential for additional features that can be added to the JSON-LD LSP. For example, hovering, go-to-definition and code actions like flattening or structuring of JSON-LD documents, are possible features for future enhancements.
  
---

# Introduction

JSON-LD is a data serialization format that is used to describe semi-structured data on the web [@JSON-LD-W3C].
It adds semantic information to JSON, among others with the `@context` property, pointing to a JSON-LD context.
This context specifies how to map properties to predicates, called aliases.
The `@id` property then again specifies the subject of the current JSON object.

JSON-LD allows you to write JSON and annotate the document with a context containing the necessary information for a JSON-LD processor to map it to RDF triples with IRIs.
Writing this JSON becomes tedious when the context grows and not all properties are easy to remember.
For example, just misspelling a JSON key can break your entire Linked Data use case.

With its increasing popularity, contexts in JSON-LD also increase in complexity.
For example, OSLO is an initiative in Flanders (Belgium) that is working to achieve interoperability by building semantic standards for different stakeholders such as government, industry and academia \footnote{\href{https://www.vlaanderen.be/digitaal-vlaanderen/onze-oplossingen/oslo}{OSLO} - Open Standaarden voor Linkende Organisaties}.
Example JSON-LD context files for their vocabularies and application profiles [are available on the website data.vlaanderen.be](https://data.vlaanderen.be).


Just like we use an editor when using functions and variables while programming, a semantic JSON-LD editor will be able to avoid common mistakes.
In this demo, we show how a JSON-LD editor can help the developer experience.
The Language Server Protocol (LSP) is a standard interface that separates the domain-specific logic from the editor's logic [@LSP-Multi], allowing editors to offer advanced features such as code completion, hover information, and go-to-definition.
By implementing an LSP for JSON-LD, developers can enjoy these advanced features and bring their editor's capabilities for JSON-LD up to par with programming languages.

<!-- What is the competition doing? JSON with JSON schema? Autocompletion with Yasgui? Turtle lsp (stardog) -->
Similar efforts have been made before, but never for JSON-LD. For example, the Yasgui editor \footnote{\href{https://triply.cc/docs/yasgui/}{Yasgui} - SPARQL editor}, a popular SPARQL human query interface, provides autocompletion based on the LOV API [@LOV]. Plugins can add autocompletion based on domain knowledge. These capabilities are built into the editor and can only be used with Yasgui.
Stardog created open-source LSPs for turtle, TRIG, SPARQL, and more, however, they only concern themselves with correct syntax and keyword auto-completion [@stardog]. 

Our demo JSON-LD LSP and installation instructions to use it with your favorite LSP capable editor can be found at [github.com/ajuvercr/jsonld-lsp](https://github.com/ajuvercr/jsonld-lsp) (MIT).

# Language Server Protocol  

The Language Server Protocol (LSP) is a JSON RPC protocol developed by Microsoft to simplify the process of integrating language-specific logic into an editor \footnote{\href{https://microsoft.github.io/language-server-protocol/}{LSP} - Language Server Protocol}. Prior to LSP, editors had to implement each programming language they wanted to support individually, resulting in an $O(n*m)$ complexity where n is the number of editors and m is the number of programming languages. With LSP, editor and language-specific logic only needs to be implemented once, resulting in a much simpler $O(n+m)$ complexity [@LSP-Multi]. LSP only concerns itself with the source files of the program and doesn't involve building, running, or debugging. This is in contrast to the Build Server Protocol \footnote{\href{https://github.com/build-server-protocol/build-server-protocol}{BSP} - Builder Server Protocol}.

To implement an LSP, you can support predefined functions like autocompletion, rename, go to definition, find all references etc. Not everything needs to be implemented, as the editor and server can negotiate capabilities. For example, to support completion the server will respond to _"textDocument/completion"_ events, this event only contains the current cursor location, as document changes are communicated with other events. The server would respond with a completion list, containing visual labels for the user, and text edits that change the document when this completion item is selected. While initializing, the server would send a _"client/registerCapability"_ request to the client that informs the client of the completion capability. 

Overall, the Language Server Protocol has greatly simplified the process of integrating language-specific logic into an editor [@LSP-editor]. LSP has made it easier for developers to work with a wide range of programming languages and editors. Currently, there exist over 130 LSP servers that cover 99 different programming languages. JSON-LD can be the 100th language to benefit from an LSP.


# Demo

Our demo presents an implementation of a JSON-LD Language Server Protocol (LSP), developed using the Rust programming language and based on a basic LSP implementation \footnote{\href{https://crates.io/crates/tower-lsp}{Tower LSP} - Crate by Eyal Kalderon}. To extract predicate mappings from the context, we rely on the JSON-LD crate \footnote{\href{https://crates.io/crates/json-ld}{JSON-LD} - Crate by Timothée Haudebourg}. The full source code and installation instructions can be found on GitHub (MIT)\footnote{\href{https://github.com/ajuvercr/jsonld-lsp}{JSON-LD LSP} - Crate by Arthur Vercruysse}.

\begin{figure}
\centering
\makebox[\textwidth][c]{
    \includegraphics[width=.7\linewidth]{./fig/completion.png}
    \includegraphics[width=.7\linewidth]{./fig/completion-id.png}
}
\caption{Screenshots showing completion functionality in NeoVim: left a list with all completion options, right a list containing the defined subject.}
\label{fig:complete}
\end{figure}


One of the key features of our LSP is code autocompletion based on the defined context. It extracts aliases from the inlined context, local contexts, and contexts hosted on the web. However, it currently does not take into account special context attributes such as context overloading or scoped contexts [@JSON-LD-W3C]. In Figure \ref{fig:complete}, you can see this in action. The context defines two aliases, "name" and "knows". When the completion event is triggered, the user can choose between these aliases and the editor will complete the chosen alias. Defined subjects can be completed when writing `@`, but will expand to more involved objects.

\begin{figure}
\centering
\makebox[\textwidth][c]{
    \includegraphics[width=.7\linewidth]{./fig/rename-1-small.png}
    \includegraphics[width=.7\linewidth]{./fig/rename-2-small.png}
}
\caption{Screenshots showing renaming functionality in NeoVim: left NeoVim asks for the new name, right the subject is renamed.}
\label{fig:rename}
\end{figure}

Additionally, our LSP implementation supports renaming subjects. This is shown in Figure \ref{fig:rename}. The user is asked for the new name and the LSP server will respond with the required text changes that change all matching subjects to the new name.

 
# Conclusion
 
This demonstration merely scratches the surface of the vast capabilities of a JSON-LD LSP. By leveraging fully-interpreted contexts, the LSP can provide more contextually-relevant suggestions, taking into account context overloading and scoped contexts. Additionally, the LSP's functionality can be expanded to include the interpretation of referenced vocabularies, allowing completion for compacted predicates, like `foaf:knows`. Despite its current limitations, the LSP already enhances the developer experience by facilitating the creation and editing of JSON-LD documents.



