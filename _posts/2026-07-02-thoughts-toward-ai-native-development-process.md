---
layout: blog
title: Thoughts toward AI Native Development Process
tags: AI
---

AI coding tools shine for greenfield projects, but teams maintaining mature services face a different reality.
I experimented with maximizing AI usage across all development phases, system design, coding, testing, and documentation, and found that the key to high-quality AI output is not better prompting, but better context management at the team level.

<!--end_excerpt-->

# Introduction

My team builds and operates data infrastructure services that have been running in production for years. We have been exploring ways to accelerate our development velocity using AI tools. Within our broader engineering organization, there are already case studies where teams built products in dramatically shorter timelines by leveraging AI. These case studies tend to share specific conditions:

* Scratch development (low compatibility cost)
* Led by one independent IC or a small focus team (low or no communication cost)
* Without a heavy development process (low process cost)

I don't think these conditions are necessarily true for fast delivery, but they are often true in the successful case studies.
Under these conditions, a project tends to be dominated by coding tasks that are relatively easy to accelerate with AI.

On the other hand, in teams that maintain mature services, it is rare to satisfy these conditions. We already have a codebase with a long history and a solid user base, handle not only new development, but also business-as-usual tasks, and have the established process for safety and compliance. Although our productivity has improved at the individual task level, particularly in coding, we haven't seen significant improvement in the end-to-end development workflow yet. We must boost the productivity of non-coding tasks, as they often dominate our work, even though this area is still developing.

I have recently been working on a project that integrates multiple managed cloud services. In this project, I tried to maximize AI usage across all phases of the development process. In this post, I share my experience and observations.

# Experiment to Leverage AI in Development Workflow

## System Design

I wrote a system design document for the project. I didn't use AI to write the document itself because I couldn't craft an effective prompt to generate one that covers the necessary details. Writing out the context needed for AI to generate the document felt almost the same as writing it myself, so I just wrote it myself.

Instead, I mainly used AI to investigate technical feasibility. This use case works well when we can provide detailed information especially actual code. I think supporting large codebase reading is one of the best AI use cases. AI is good at navigating large codebase, which significantly accelerate our learning speed.

On the other hand, it works poorly when only fragmented information, e.g. product document, blog posts, is available. These information sources often cover only major use cases and do not exhaustively explain actual behaviors. They also tend to contain outdated information. Even if the source information is incomplete or outdated, AI treats it as the absolute truth and replies based only on that. Furthermore, because AI tends to tailor its responses to align with the user's intent, it often outputs incorrect conclusions rather than "I don't know" when the source information is incomplete. It confuses humans and takes up time for verification.

At present, my impression is that it's still difficult to let AI write a holistic design document from scratch. However, I feel that there is a possibility to improve the method to manage system design documents in more AI oriented way. I discuss it in later sections.

## Coding

Since the effectiveness of AI coding has already been well-proven, I will not go into the details here. Instead, I describe a few observations from the perspective of optimizing the entire software development process.

I noticed that it becomes much easier to craft a prompt to generate intended code with AI when well-defined design documents are provided as context. Particularly, when developing application code, AI can generate high quality code only with the following additional guides:

* Tech stack and coding convention
    * Provided code of other services that use the same tech stack as references
* Implementation details that were missing on high-level system design
    * These decisions about implementation details are recorded in documents

On the other hand, regarding infrastructure code like Terraform and cloud platform configurations, I needed to provide more guide for AI to generate working code. One of the reasons is that not much context was available for that task. The high-level system design doesn't cover details of infrastructure and deployment strategy as they are implementation details. Also, I used some new cloud platform tooling for this project, so I could not provide sufficient context initially.

Learning here is that even though AI is getting more capable of coding, humans still need to craft context and prompts properly to get intended output. Besides, we also need to critically review AI output unless we entirely trust AI (and it's untrue at present). Humans still need a solid mental model about the system to perform these roles. While coding is a process for development, it simultaneously functioned to deepen the understanding of the software and system being built. It is a challenge how we develop knowledge about systems when AI largely replaces coding process.

## End-to-end Testing

I automated end-to-end testing using AI. In my opinion, this was the most beneficial use of AI across overall development workflow in this project. It is because the integration is core of this project. Since we prioritized keeping development and maintenance costs low, we chose to leverage existing components and managed cloud services rather than custom development. Consequently, a weight of end-to-end integration testing becomes relatively large in the overall development workflow. Because the workload distribution within the overall development workflow depends on the specific project or team, it requires a case-by-case evaluation.

Typical tasks of end-to-end test are as follows. All of them are done by AI. Output of each task is stored in the repository.

* Write a test requirement document
    * Build exhaustive test plan based on the system requirements
    * Prerequisites to run test cases
    * Write test and verification steps that AI can execute
* Run test cases and collect test evidence
    * Record input and output of test and verification steps
    * When a test case failed, it is retried after bugs are fixed
* Summarize test result

While these tasks are time consuming when humans work on them manually, AI can finish them significantly faster. I just reviewed output documents of each task, which is dramatically lower effort than performing all of tasks above manually. Also, if we ask the end-to-end test for QA team, we also need a lot of communication, e.g. sharing the background, test plan review, etc.

And again, the documents and code created in the previous phases worked greatly as context for AI. I created Claude Code skills about user-facing interfaces of this feature (API endpoints and query CLI) and prompted like:

> Think end-to-end exhaustive test plan based on product and system designs. You can use APIs and CLI for testing. Write a test requirement document first.

Then, AI extracted the test factors based on the contexts. Although I needed a few more prompts to get a sufficient quality test document, I didn't need to write every single detail about test considerations.

In the case of this project, we had only short-running test cases. Automating long-running test cases, e.g. load testing, running heavy queries, a background job that runs periodically, requires some more ingenuity.

## Documenting

During working on production readiness, I wrote requirement documents and user guide documents using AI.

The requirement document is almost just a copy of the system design document, but the format is adjusted to our internal template. We need it since our process requires it for security review. As the required content is already available on the system design document, I could smoothly copy it into the required format using a Claude Code skill that generates documents in the template format.

I also wrote user guide documents for customers. They were written using the design documents and test documents as context. The design documents describe major user stories and test documents serve as an exhaustive list of working functionalities. As these documents already cover required information, AI just arranged it for customers.

It takes time for humans to arrange the format and tone of documents depending on expected audiences, but this task is also significantly faster with AI.

# Observations and Discussion

Through my experiment, I've realized (as many of you may already know) that the principle for securing high-quality output from AI is remarkably simple. It all comes down to the quality context provided. As long as a model has sufficiently detailed context, it is capable of generating good outputs without requiring extensive prompting. I've observed this consistent pattern across almost every type of task.

The impact of maintaining the quality context cascades to the succeeding phases in the development workflow. The coding task leverages the context of system design. The end-to-end testing task leverages the context of system design and coding. The context and output of a task should be recorded and maintained so that they serve as context for future tasks. Context from the past development rounds also helps future development. It should be properly recorded and leveraged later.

## Managing Contexts at Teams

Despite the importance of context, we don't have a system to manage it effectively at team level. While some common contexts are shared as CLAUDE.md/AGENTS.md and skills, context to do a specific task is mostly crafted by individual engineers now, as far as I know. Building detailed context for engineering tasks from scratch requires huge effort, e.g. describing overall system architecture, system interface, component dependencies, test strategy, historical decisions about why the system is designed and implemented in the current way, etc. We should manage the detailed context to ensure consistent AI output quality.

In my opinion, we should discuss this point before we discuss applying AI tools to our development workflow. The capabilities of AI are largely determined by the context provided. That is, what tasks AI can automate depends on the context quality.

## Another Example: Mono-repo with Granular Decision Records

I came across a development process of another team, which addresses the same context management problem, but in a different way. It has 2 major differences from my approach as follows:

### Manages application and infrastructure code in a single repository

Unlike our typical setup, this team manages code in mono-repo style. Mono-repo suits comprehensive context management as all relevant code is stored in a single place. It is possible to share context across repositories in multi-repo style since AI tools can refer to code and documents outside of the repository. However, at least we need to tell where AI should look into to seek context. This issue is automatically mitigated in mono-repo style.

### Manages decision record in more fine granularity

The system design, architecture decision record (ADR) and implementation plan are recorded under a `/plans` directory. A developer creates a subdirectory when they work on a development item that typically takes 1 to 5 days.

It appends granular decision records instead of updating a single design document. While this approach is different from our current one, I feel this is more desirable when AI tools are available. A single source of truth design document is beneficial for humans to understand the current situation. However, it usually takes time to write it from scratch and is also problematic to keep it updated, e.g.

* Developers may forget to update it
* When multiple work streams are running concurrently, it's not straightforward to reflect the current state

Since the cost of prototyping has drastically reduced by AI coding, iterating on small design decisions and implementations is better to accelerate our feedback cycle. Small ADRs are problematic for humans to follow directly, but we can also use AI to generate a snapshot of current design from ADRs. I guess we still need to maintain such a snapshot document to confirm the integrity of the overall system design, but we can leverage AI for the maintenance. We can expect reducing documentation overhead with that style.

# How it can be better?

## Move Documentation Closer to Code

We currently manage technical documents mainly in wiki tools. We plan to move them to where code is managed, i.e. Git repositories, for better discoverability by AI tools.
While AI tools can technically read information from outside the repository, they are more likely to find it when the documents are stored in the same place. e.g. when AI searches a word using grep, it can naturally look up documents along with code.

Due to our multi-repo setup, there is no ideal place in Git to store cross-repository technical documentation and shared system architecture decision records. We need to consider how to share these documents as context across repositories.

## Explore Cross-repo Context Sharing

We need to record design decisions that impact a large portion of the system. It isn't obvious where to store such information with a multi-repo setup. Migration to mono-repo is an option since it suits AI context management. However, migrating from multi-repo to mono-repo involves major effort particularly in CI/CD migration. It's unrealistic to consolidate all existing repositories into mono-repo even at the team level.

Instead, I'm considering the meta-repo / virtual mono-repo pattern (ref: [The Meta-Repo Pattern](https://devnewsletter.com/p/meta-repo-pattern/))

> Rather than restructuring codebases (an expensive and politically fraught undertaking), teams are building what amount to maps: lightweight repositories that sit above their project code and provide agents with the context they lack. Practitioners call them "meta-repos" or "virtual monorepos." They contain no application code, only documentation, manifests, and tooling that orient an AI agent across an entire system.

There are several approaches for meta-repo / virtual mono-repo setup and each has pros and cons.
Experiments are required to find an approach that fits your workstyle. At least, their implementation cost is much lower than migration to mono-repo. It's worth trying.

# Summary

I believe that building and maintaining context at team level instead of individual level is the most critical point to expand AI capability and adoption. Toward AI native development, we need to improve our development environment and process for more efficient context management.
