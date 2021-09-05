---
author: Thierry Onkelinx
categories:
- reproducible research
- version control
date: 2017-08-23
output:
  md_document:
    preserve_yaml: true
    variant: gfm
slug: git_workflow_ecologists
tags:
- git
title: A git workflow for ecologists
---

# Git

For those how don’t know [git](https://git-scm.com/), it is a free and
open source distributed version control system designed to handle
everything from small to very large projects with speed and efficiency.
I use git daily, including for this
[blog](https://github.com/thierryo/my_blog). Have a look at
[Wikipedia](https://en.wikipedia.org/wiki/Git) for more background.

Although it requires some overhead, it saves a lot of time once you get
the hang of it. Why? Because you have the confidence that you can go
back to any point in the history of a project. So you can explore new
things without risking to ruin everything. The new things don’t work
out? Just go back to the last good point in the history and start over.

Each point in the history is called a `commmit`. A `commit` contains all
essential information on *what* needs to change to recreate the current
state starting from the previous `commit`. It also contains useful
metadata: *who* created the `commit`, *when* and *why[1]*.

Git works great with plain text files like R scripts, RMarkdown files,
data in txt or csv format, … You can add binary files (Word, Excel, pdf,
jpg, …) to a git project, but not as efficient as plain text files and
with less options. In case of a plain text file, git notes which lines
in the file are removed and where a line was inserted. A change in a
line is a combination of removing the old line and inserting the new
line. Have a look a [this
commit](https://github.com/ThierryO/my_blog/commit/fcab2804b75e7848283ef460f945f93aa3538bf5)
if you want a real life example. Such granular approach is not available
for binary files. Hence the old version is removed and the new version
is added.

# Target audience for this workflow

The workflow is useful for anyone with basic computer skills. The
workflow does not use all whistles and bells available in git. Only the
minimal functionality which is all accessible via either a graphical
user interface (GUI) or a website. We target ecologists who often write
R scripts and have no prior knowledge on version control systems.

This workflow seems to work for a team of scientists how work on the
same project and have all write access to that project (`repository` in
git terminology).

# Basic workflow

## Use case

-   First `repositories` of git novices.
-   Initial start of a `repository`.

It is no longer valid as soon as more than one user commits to the
`repository`.

## Principle

The basic workflow is just a simple linear history. The user makes a set
of changes and commits those changes. This is repeated over and over
until the project is finished. The resulting history will look like [fig
1](#basic).

One extra step is at least a daily `push` to another machine. This
creates (or updates) a copy of the entire project history to that other
machine. And thus serves as a backup copy. Therefore this should be done
at least daily. The easiest way is to use an on-line service like
[GitHub](https://github.com), [Bitbucket](https://bitbucket.com),
[GitLab](https://gitlab.com), … GitHub is free for public repositories
and is popular for freeware open source projects. Bitbucket offers free
private repositories but only for small teams (max. 5 users). Having the
repository on an on-line platform has another benefit: it is easy to
share your work and collaborate.

<a id="basic"></a>
<img src="../../../post/2017-08-23-a-git-workflow-for-ecologists_files/figure-gfm/basic-1.svg" title="Fig 1. An example of the history of a basic workflow" alt="Fig 1. An example of the history of a basic workflow" width="576" style="display: block; margin: auto;" />

# Branching workflow with pull requests

## Use case

-   Working with several people on the same repository
-   More experienced git users

## Principle

1.  Commits are only created in `feature branches`, not in the
    `master branch`.
2.  Finalised `branches` are `merged` into the `master branch` by
    `pull requests`.

## Branch

The [basic workflow](#basic-workflow) has a single `branch` which is
called `master`. Git makes it easy to create new `branches`. A `branch`
starts from a specific commit. Each user should create a new `branch`
when he starts working on a new feature in the repository. Because each
user works in his own branch, he is the only one writing to this part of
the history. This avoids a lot of conflicts. [Fig 2](#branching)
illustrates how the history looks like when a few branches are created.

<a id="branching"></a>
<img src="../../../post/2017-08-23-a-git-workflow-for-ecologists_files/figure-gfm/branching-1.svg" title="Fig 2. An example of a history with a few feature branches" alt="Fig 2. An example of a history with a few feature branches" width="576" style="display: block; margin: auto;" />

## Pull request

Creating branches is fine, but they diverge the history of the
repository. So we need a mechanism to `merge` branches together. In this
workflow we will work on a feature branch until it is finished. Then we
merge it into the master branch. [Fig 3](#pull-request) illustrates the
resulting history. This can be done locally using a `merge`, but it is
safer to do it on-line via a `pull request`.

<a id="pull-request"></a>
<img src="../../../post/2017-08-23-a-git-workflow-for-ecologists_files/figure-gfm/pull-request-1.svg" title="Fig 3. An example of a history after two pull requests" alt="Fig 3. An example of a history after two pull requests" width="576" style="display: block; margin: auto;" />

A `pull request` is a two step procedure. First you create the
`pull request` by indicating via the webapp which branches you would
like to `merge`. The second step is to `merge` the pull request.
Documentation on how to handle `pull requests` can be found on the
websites of
[GitHub](https://help.github.com/articles/about-pull-requests/),
[Bitbucket](https://www.atlassian.com/git/tutorials/making-a-pull-request)
and
[GitLab](https://docs.gitlab.com/ee/gitlab-basics/add-merge-request.html).

Pull requests have several advantages over local merges

1.  It works only when the branches are pushed to the on-line copy of
    the repository. This ensures not only a backup but also gives access
    to the latest version to your collaborators.
2.  All pull requests are done against the common (on-line) master
    branch. Local merges would create diverging master branches which
    will create a lot of conflicts.
3.  Since the pull request is a two step procedure, one user can create
    the pull request and another (e.g. the project leader) can do the
    actual merge.
4.  The pull request gives an overview of the aggregated changes of all
    the commits in the pull request. This makes it easier to get a
    feeling on what has been changed within the range of the pull
    request.
5.  Most on-line tools allow to add comments and reviews to a pull
    request. This is useful to discuss a feature prior to merging it. In
    case additional changes are required, the user should update his
    feature branch. The pull request gets automatically updated.

## Conflicts

Conflicts arise when a file is changed at the same location in two
different branches and with different changes. Git cannot decide which
version is correct and therefore blocks the merging of the pull request.
It is up to the user to select the correct version and commit the
required changes. See on-line
[tutorials](https://help.github.com/articles/resolving-a-merge-conflict-using-the-command-line/)
on how to do this. Once the conflicts are resolved, you can go ahead and
merge the pull request. This is illustrated in [fig 3](#pull-request).
First `master` is merged back into `feature B` to handle the merge
conflict and then `feature B` is merged into `master`.

*What if I choose the wrong version?* Don’t panic, both versions remain
in the history so you don’t loose any. So you can create a new branch
starting for the latest commit with the correct version and merge that
branch.

# Flowcharts

Here a a few flowcharts that illustrate several components of the
branching workflow with pull requests. [Fig 4](#prepare-repo)
illustrates the steps you need when you want to start working on a
project. Once you have a local `clone` of the repository you can
`check out` the required feature branch ([fig 5](#create-branch)). The
last flowchart handles working in a feature branch and merge it when
finished ([fig 6](#commit)).

<a id="prepare-repo"></a>
<img src="../../../post/2017-08-23-a-git-workflow-for-ecologists_files/figure-gfm/prepare-repo-1.svg" title="Fig 4. Flowchart for preparing a repository." alt="Fig 4. Flowchart for preparing a repository." width="576" style="display: block; margin: auto;" />

<a id="create-branch"></a>
<img src="../../../post/2017-08-23-a-git-workflow-for-ecologists_files/figure-gfm/create-branch-1.svg" title="Fig 5. Flowchart for changing to a feature branch." alt="Fig 5. Flowchart for changing to a feature branch." width="576" style="display: block; margin: auto;" />

<a id="commit"></a>
<img src="../../../post/2017-08-23-a-git-workflow-for-ecologists_files/figure-gfm/commit-1.svg" title="Fig 6. Flowchart for applying changes in a feature branch." alt="Fig 6. Flowchart for applying changes in a feature branch." width="576" style="display: block; margin: auto;" />

# Rules for collaboration

1.  Always commit into a feature branch, never in the master branch.
2.  Always start features branches for the master branch.
3.  Only work in your own branches.
4.  Never merge someone else’s pull request without their consent.
5.  Don’t wait too long for merging a branch. Keep the scope of a
    feature branch narrow.

## Exceptions

**Starting branches not from master**

In case you want to apply a change to someone else’s branch. Create a
new branch starting from the other’s branch, add commits and create a
pull request. Ask the branch owner to merge the pull request. Basically
you use someone else’s branch as the master branch.

**Working with multiple users in the same branch**

This is OK as long as users don’t work simultaneously in the branch.

-   Person A create the branch
-   Person A adds commits
-   Person A pushes and notifies person B
-   Person B adds commits
-   Person B pushes and notifies the next person
-   …
-   Person A creates a pull request

## Session info

These R packages were used to create this post.

    #> ─ Session info ───────────────────────────────────────────────────────────────
    #>  setting  value                       
    #>  version  R version 4.1.1 (2021-08-10)
    #>  os       Ubuntu 18.04.5 LTS          
    #>  system   x86_64, linux-gnu           
    #>  ui       X11                         
    #>  language nl_BE:nl                    
    #>  collate  nl_BE.UTF-8                 
    #>  ctype    nl_BE.UTF-8                 
    #>  tz       Europe/Brussels             
    #>  date     2021-09-05                  
    #> 
    #> ─ Packages ───────────────────────────────────────────────────────────────────
    #>  package     * version date       lib source        
    #>  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.1.0)
    #>  cli           3.0.1   2021-07-17 [1] CRAN (R 4.1.1)
    #>  codetools     0.2-18  2020-11-04 [1] CRAN (R 4.1.0)
    #>  colorspace    2.0-2   2021-06-24 [1] CRAN (R 4.1.0)
    #>  crayon        1.4.1   2021-02-08 [1] CRAN (R 4.1.0)
    #>  DBI           1.1.1   2021-01-15 [1] CRAN (R 4.1.0)
    #>  diagram     * 1.6.5   2020-09-30 [1] CRAN (R 4.1.0)
    #>  digest        0.6.27  2020-10-24 [1] CRAN (R 4.1.0)
    #>  dplyr       * 1.0.7   2021-06-18 [1] CRAN (R 4.1.0)
    #>  ellipsis      0.3.2   2021-04-29 [1] CRAN (R 4.1.0)
    #>  evaluate      0.14    2019-05-28 [1] CRAN (R 4.1.0)
    #>  fansi         0.5.0   2021-05-25 [1] CRAN (R 4.1.0)
    #>  farver        2.1.0   2021-02-28 [1] CRAN (R 4.1.0)
    #>  fastmap       1.1.0   2021-01-25 [1] CRAN (R 4.1.0)
    #>  generics      0.1.0   2020-10-31 [1] CRAN (R 4.1.0)
    #>  ggplot2     * 3.3.5   2021-06-25 [1] CRAN (R 4.1.0)
    #>  glue          1.4.2   2020-08-27 [1] CRAN (R 4.1.0)
    #>  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.1.0)
    #>  here        * 1.0.1   2020-12-13 [1] CRAN (R 4.1.0)
    #>  highr         0.9     2021-04-16 [1] CRAN (R 4.1.0)
    #>  htmltools     0.5.2   2021-08-25 [1] CRAN (R 4.1.1)
    #>  knitr       * 1.33    2021-04-24 [1] CRAN (R 4.1.0)
    #>  labeling      0.4.2   2020-10-20 [1] CRAN (R 4.1.0)
    #>  lifecycle     1.0.0   2021-02-15 [1] CRAN (R 4.1.0)
    #>  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.1.0)
    #>  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.1.0)
    #>  pillar        1.6.2   2021-07-29 [1] CRAN (R 4.1.1)
    #>  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.1.0)
    #>  purrr         0.3.4   2020-04-17 [1] CRAN (R 4.1.0)
    #>  R6            2.5.1   2021-08-19 [1] CRAN (R 4.1.1)
    #>  rlang         0.4.11  2021-04-30 [1] CRAN (R 4.1.0)
    #>  rmarkdown     2.10    2021-08-06 [1] CRAN (R 4.1.1)
    #>  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.1.0)
    #>  rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.1.0)
    #>  scales        1.1.1   2020-05-11 [1] CRAN (R 4.1.0)
    #>  sessioninfo   1.1.1   2018-11-05 [1] CRAN (R 4.1.0)
    #>  shape       * 1.4.6   2021-05-19 [1] CRAN (R 4.1.0)
    #>  stringi       1.7.4   2021-08-25 [1] CRAN (R 4.1.1)
    #>  stringr       1.4.0   2019-02-10 [1] CRAN (R 4.1.0)
    #>  tibble        3.1.4   2021-08-25 [1] CRAN (R 4.1.1)
    #>  tidyselect    1.1.1   2021-04-30 [1] CRAN (R 4.1.0)
    #>  utf8          1.2.2   2021-07-24 [1] CRAN (R 4.1.1)
    #>  vctrs         0.3.8   2021-04-29 [1] CRAN (R 4.1.0)
    #>  withr         2.4.2   2021-04-18 [1] CRAN (R 4.1.0)
    #>  xfun          0.25    2021-08-06 [1] CRAN (R 4.1.1)
    #>  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.1.0)
    #> 
    #> [1] /home/thierry/R/x86_64-pc-linux-gnu-library/4.0
    #> [2] /usr/local/lib/R/site-library
    #> [3] /usr/lib/R/site-library
    #> [4] /usr/lib/R/library

[1] Assuming that the user entered a sensible commit message.
