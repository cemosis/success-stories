%%% Class for compiling success stories.
%%% Author: Antoine Lejay 
%%% Version: 2.1
%%% Date: 2019-10-01

%% This sould be compiled with *lualatex*

% https://tex.stackexchange.com/questions/5036/how-to-prevent-latex-from-hyphenating-the-entire-document/5039
\tolerance=1
\emergencystretch=\maxdimen
\hyphenpenalty=10000
\hbadness=10000

%%% TODO select language

\RequirePackage[svgnames]{xcolor} % to avoid option clash
\LoadClass[tikz]{standalone}
\RequirePackage[T1]{fontenc}
\RequirePackage{cmap}  % for copy and paste unicode characters in pdf
%\RequirePackage[utf8]{inputenc} % no need with lualatex
\RequirePackage{pgfkeys}
\RequirePackage{tikz}
\RequirePackage{enumitem}
\RequirePackage[protrusion=true,factor=1000]{microtype}
\RequirePackage{etoolbox}
\RequirePackage{ragged2e}
\RequirePackage{hyperref}
\RequirePackage[main=english,french]{babel}
\RequirePackage{csquotes}

%% Load tikzlibrary
\usetikzlibrary{calc}
\usetikzlibrary{patterns}
\usetikzlibrary{babel}


%%%% STYLES
\tikzset{illustration style/.style={}}
\tikzset{math description style/.style={}}
\tikzset{problem description style/.style={}}
\tikzset{goal style/.style={}}
\tikzset{academic style/.style={}}
\tikzset{industrial style/.style={}}

\tikzset{academic logo style/.style={}}
\tikzset{industrial logo style/.style={}}
\tikzset{highlight style/.style={}}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FONT SPECIFICATION (compile with lualatex)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\usepackage{fontspec}
\setmainfont{Franklin Gothic Book}

\newfontface\thetitlefont{Calibri}[LetterSpace=-1,WordSpace=1]
\DeclareTextFontCommand\thetitle{\fontsize{44pt}{53pt}\selectfont\thetitlefont}

% For the one-line, this is the real scale
\newfontface\theonelinefont{Calibri Italic}  
\DeclareTextFontCommand\theoneline{\fontsize{24pt}{29pt}\selectfont\theonelinefont}

\newfontface\blocktitlefont{Franklin Gothic Book}
\DeclareTextFontCommand\blocktitle{\fontsize{16pt}{18pt}\selectfont\blocktitlefont}

\newfontface\blocksocietalfont{Franklin Gothic Book}[LetterSpace=-1,WordSpace=0.5]
\DeclareTextFontCommand\blocksocietal{\fontsize{20pt}{24pt}\selectfont\blocksocietalfont}

\newfontface\blocktitleresultfont{Franklin Gothic Book}
\DeclareTextFontCommand\blocktitleresult{\fontsize{16pt}{18pt}\selectfont\blocktitleresultfont}



\newfontface\highlightfont{Franklin Gothic Bold} % or Franklin Gothic Book

% To highlight a word in the benefits box
\newcommand{\Impact}[1]{{\fontsize{22pt}{26pt}\selectfont #1}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PAGE STYLE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\pagestyle{empty}
\setlength{\parindent}{0pt}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% COLORS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\definecolor{templateblue}{RGB}{129,193,145}
\definecolor{templatemarroon}{RGB}{136,123,86}
\definecolor{highlightcolor}{HTML}{d4eaeb}
\definecolor{arrowcolor}{HTML}{0365c0}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% METADATA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newif\ifdigitaltwin % Show the Digital Twin logo

% Define some metadata keys
\pgfkeys{/metadata/.cd,
    author/.initial={[auteurs]},
    date/.initial={0000-00-00},
    keywords/.initial={},
    institution/.initial={},
    email/.initial={},
    identifier/.initial={}, % a name that should be unique
    versionno/.initial={1}, % version number
    contact/.initial={[contact within AMIES]},
    url/.initial={https://www.agence-maths-entreprises.fr}, % link for the info icon
    digital_twin/.is if=digitaltwin,
}

% handler for the lang, should be one of the babel options
\pgfkeys{
    /metadata/lang/.initial={english}
}

% Define a boolean flag to know whether or not we are dealing with a 
% working or a final version
\newbool{working}

% The key version is either working or anything else (normally, final, but this is not
% checked
\pgfkeysdef{/metadata/version}{%
\ifstrequal{#1}{working}{\booltrue{working}}{\boolfalse{working}}}

% handler for the lang, should be one of the babel options
\pgfkeys{
    /metadata/version/.default={working}
}

% Height of the industrial logo, 1.5cm by default
\newcommand{\industriallogoheight}{1.5cm}
\pgfkeys{/project/industrial/industrial logo height/.code={\def\industriallogoheight{#1}}}



% handler for unknown keys
\pgfkeys{
    /metadata/.unknown/.code={\typeout{warning: unknown metadata key ‘\pgfkeyscurrentkey’.}},
}

% Define the \MetaData command for setting up metadata.
\newcommand{\MetaData}[1]{
    \pgfkeys{/metadata/.cd,#1}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRINT INFO FOR WORKING VERSION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This command should be included in a tikzpicture environment.
\newcommand{\printversionifworking}{%
    \ifbool{working}{% if working version
    \node[anchor=north east,rotate=90,inner sep=0pt,color=LightGray!80!black] (amiesfsmp) at ($(this page north west)+(0.3cm,-0.3cm)$) 
	{\textcolor{red}{WORKING VERSION \# \pgfkeysvalueof{/metadata/versionno} / \pgfkeysvalueof{/metadata/date}}};
    }{ % otherwise, do nothing
}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LENGTHS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newlength{\DescriptionGoalsWidth}
\setlength{\DescriptionGoalsWidth}{7cm}


\tikzset{tight/.style={inner sep=0pt,outer sep=0pt}}  % Tight boxes

%\tikzset{every node/.append style={tight,draw=red}}  % Every node is tight



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% KEYS DEFINITION
%%%
%%% These keys are used to define the content
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\pgfkeyssetvalue{/project/name}{\textcolor{red}{Name of the project}}
\pgfkeyssetvalue{/project/oneline}{\textcolor{red}{One line description}}
\pgfkeyssetvalue{/project/h2020}{\textcolor{red}{H2020 Challenge}}
\pgfkeyssetvalue{/project/sector}{\textcolor{red}{sector}}
\pgfkeyssetvalue{/project/math description}{\textcolor{red}{mathematical and computational methods description}}
\pgfkeyssetvalue{/project/problem description}{\textcolor{red}{problem description}}
\pgfkeyssetvalue{/project/goal}{\textcolor{red}{challenges and goals}}
\pgfkeyssetvalue{/project/academic/name}{name of the academic partner}
\pgfkeyssetvalue{/project/academic/logo}{logo of the academic partner}
\pgfkeyssetvalue{/project/academic/description}{\textcolor{red}{short description}}

\pgfkeyssetvalue{/project/industrial/name}{name of the industrial partner}
\pgfkeyssetvalue{/project/industrial/description}{\textcolor{red}{short description}}

\pgfkeyssetvalue{/project/results}{\textcolor{red}{results}}
\pgfkeyssetvalue{/project/highlight}{\textcolor{red}{highlight}}
\pgfkeyssetvalue{/project/contribution}{\textcolor{red}{contribution}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LOGOS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Undefined logo
\def\logodefault{\begin{tikzpicture}\draw (0,0) rectangle (1.5cm,1.5cm);
	\draw (0,0) -- (1.5cm,1.5cm); \draw (0,1.5cm) -- (1.5cm,0);\end{tikzpicture}}

%% Logo for the industrial partnership
\let\industriallogo=\logodefault
\pgfkeys{/project/industrial/logo/.code={%
	\ifstrempty{#1}{\let\industriallogo=\logodefault}%
	{\def\industriallogo{\includegraphics[height=\industriallogoheight]{#1}}}%
    }}
%% Logo for the industrial partnership
\let\academiclogo=\logodefault
\pgfkeys{/project/academic/logo/.code={%
	\ifstrempty{#1}{\let\academiclogo=\logodefault}%
	{\def\academiclogo{\includegraphics[height=1.5cm]{#1}}}%
    }}

%% Box for the illustration by default
\def\illustrationdefault{\begin{tikzpicture}\draw (0,0) rectangle (3cm,2.7cm);
	\draw (0,0) -- (3cm,2.7cm); \draw (0,2.7cm) -- (3cm,0);\end{tikzpicture}}

%% Height for the illustration (default value) 
\def\illustrationheight{3cm}
%% Parameters for the illustration
\pgfkeys{
    /project/illustration/height/.store in=\illustrationheight,
    /project/illustration/img/.code={%
	\ifstrempty{#1}{\let\illustration=\illustrationdefault}%
	{\def\illustration{\includegraphics[height=\illustrationheight]{#1}}}%
    }}
%% Legend for the illustration
\pgfkeyssetvalue{/project/illustration/legend}{\textcolor{red}{Légende}}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% TO SET UP THE CONTENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To set up the content
\newcommand{\Setup}[1]{\pgfkeys{/project/.cd,#1}}
\newcommand{\SetupAcademic}[1]{\pgfkeys{/project/academic/.cd,#1}}
\newcommand{\SetupIndustrial}[1]{\pgfkeys{/project/industrial/.cd,#1}}
\newcommand{\SetupIllustration}[1]{\pgfkeys{/project/illustration/.cd,#1}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For the titles of the blocks
\tikzset{block title/.style={inner sep=0pt,outer sep=0pt,color=templateblue,align=left}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% COMPOSITION OF THE FIRST PAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\CreateFirstPage}{
% should be done like this 
% see https://tex.stackexchange.com/questions/136659/how-to-pass-a-macro-as-the-argument-to-selectlanguage
\pgfkeys{/metadata/lang/.get=\documentlang}
\expandafter\selectlanguage\expandafter{\documentlang} 

\begin{tikzpicture}

    % The global box
    \useasboundingbox (0,0) rectangle (29.7cm,21cm);

    %% Cordinates of corners
    \coordinate (this page south west) at (0,0);
    \coordinate (this page north west) at (0,21cm);
    \coordinate (this page south east) at (29.7cm,0);
    \coordinate (this page north east) at (29.7cm,21cm);
    \coordinate (this page east) at (29.7cm,10.5cm);

    %%% Inner margins
    %\coordinate (this page inner south west) at (2cm,1cm);
    \coordinate (this page inner north west) at (3cm,20cm);
    %\coordinate (this page inner south east) at (27.7cm,1cm);
    %\coordinate (this page inner north east) at (27.7cm,20cm);
    \coordinate (this page inner east) at (27.7cm,10.5cm);

    % Print info in the upper left corner for working versions
    \printversionifworking

    % Copyright
    \node[anchor=south west,rotate=90,inner sep=0pt,color=LightGray!80!black] (amiesfsmp) at ($(this page south east)+(-0.3cm,0.3cm)$) 
	{\textcopyright\ Agence Maths Entreprises \& Fondation Sciences Mathématiques de Paris};

    % Name of the project
	\node[tight,anchor=north west,color=templatemarroon] (main) at ($(this page north west)+(2cm,-1cm)$)
	{\ignorespaces\thetitle{\pgfkeysvalueof{/project/name} }};

    % One line description
    \node[tight,anchor=north west,color=templateblue] (desc) at ([yshift=-0.3cm]main.south west)
	{\ignorespaces\theoneline{\pgfkeysvalueof{/project/oneline} }};

    % H2020 sociatal challenges
    % Font is Franklin Gothic Book, size=10pt
    \path let \p1=(desc.south),\p2=(this page east) in node[tight,anchor=north east,xshift=-2.5cm,yshift=-0.3cm,color=templatemarroon,text width=29cm,align=right] (h2020) at (\x2,\y1)
    {\blocksocietal{H2020 SOCIETAL CHALLENGES: \pgfkeysvalueof{/project/h2020}}};

    % Productive sector
    % Font is Franklin Gothic Book, size=10pt
    \path let \p1=(h2020.south),\p2=(this page east) in node[tight,anchor=north east,xshift=-2.5cm,yshift=-0.3cm,color=templatemarroon] at (\x2,\y1)
    {\blocksocietal{PRODUCTIVE SECTOR:  \pgfkeysvalueof{/project/sector}}};

 % Mathematical and computational methods
\node[anchor=north west,tight,math description style]
(math)
at ($(this page north east)+(-19cm,-6cm)$)
    {
    \begin{minipage}{16.5cm}

	\tikz \node[block title]{\blocktitle{MATHEMATICAL AND COMPUTATIONAL METHODS}};

    \smallskip
    \RaggedRight
    \fontsize{16pt}{20pt}\selectfont\color{templatemarroon} % Frankin Gothic Book 
	\pgfkeysvalueof{/project/math description}
    \end{minipage}
    };


    % Illustration

    \node[tight,anchor=north west,xshift=1cm,yshift=-0.5cm,at=(math.south west),illustration style] (illustration) 
    { \illustration };

    \node[anchor=west,xshift=0.5cm,align=left,text width=4cm,font=\fontsize{14pt}{18pt}\selectfont] at (illustration.east)
    {\color{templatemarroon}\pgfkeysvalueof{/project/illustration/legend}};
	

% Problem description
\node[anchor=north west,tight,problem description style] (probl desc) 
at ($(this page north west)+(2cm,-6cm)$)
    {\begin{minipage}{\DescriptionGoalsWidth}
	    \tikz \node[block title]{\blocktitle{PROBLEM}\\[0.2em] \blocktitle{DESCRIPTION}};

    \smallskip
    \RaggedRight
    \fontsize{16pt}{20pt}\selectfont\color{templatemarroon} % Frankin Gothic Book 
	\pgfkeysvalueof{/project/problem description}
    \end{minipage}
    }; % end of problem description

    % challenges and goals
    \node[anchor=north west,tight,yshift=-0.5cm,goal style] at (probl desc.south west)
    {
    \begin{minipage}{\DescriptionGoalsWidth}
	\tikz \node[block title]{\blocktitle{CHALLENGES}\\[0.2em] \blocktitle{AND GOALS}};

    \smallskip
    \RaggedRight
    \fontsize{16pt}{20pt}\selectfont\color{templatemarroon} % Frankin Gothic Book 
	\pgfkeysvalueof{/project/goal}
    \end{minipage}
    };


    % %%% GUIDE
    % \draw[red,thick] (this page north west) -- (this page south east);
    % \draw[red,thick] (this page north east) -- (this page south west);
    % \draw[red,thick] ([xshift=-1cm]this page north east) -- ([xshift=-1cm]this page south east);
    % \foreach \i in {0,1,...,20}
    % {
	% \draw[red,thick] (28.4cm,\i*1cm) -- (29cm,\i*1cm);
    % }

    % \draw[red,thick] ([yshift=-3cm]this page north east) -- ([yshift=-3cm]this page north west);
    % \foreach \i in {0,1,...,29}
    % {
	% \draw[red,thick] (\i*1cm,18cm) -- (\i*1cm,18.5cm);
    % }
\end{tikzpicture}
}
%% / end of CreateFirstPage

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% COMPOSITION OF THE SECOND PAGE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\CreateSecondPage}{
\begin{tikzpicture}

    \useasboundingbox (0,0) rectangle (29.7cm,21cm);

    %%% Outer margins
    \coordinate (this page south west) at (0,0);
    \coordinate (this page north west) at (0,21cm);
    \coordinate (this page south east) at (29.7cm,0);
    \coordinate (this page north east) at (29.7cm,21cm);

    %%% Inner margins
    \coordinate (this page inner south west) at (2cm,1cm);
    \coordinate (this page inner north west) at (2cm,20cm);
    \coordinate (this page inner south east) at (27.7cm,1cm);
    \coordinate (this page inner north east) at (27.7cm,20cm);

    % Print info in the upper left corner for working versions
    \printversionifworking

    % Copyright
    \node[anchor=south west,scale=1,rotate=90,inner sep=0pt,color=LightGray!80!black] (amiesfsmp) at ($(this page south east)+(-0.3cm,0.3cm)$) 
	{\textcopyright\ Agence Maths Entreprises \& Fondation Sciences Mathématiques de Paris};

    % Name of the project
	\node[tight,anchor=north west,color=templatemarroon] (main) at ($(this page north west)+(2cm,-1cm)$)
	{\ignorespaces\thetitle{\pgfkeysvalueof{/project/name} }};

    %% One line description
	\node[tight,anchor=north west,color=templateblue] (desc) at ([yshift=-0.3cm]main.south west)
	{\ignorespaces\theoneline{\pgfkeysvalueof{/project/oneline}} };

    %%%% Results and benefices title
    \node[anchor=north west,scale=2.5,tight,color=templatemarroon] (result title) at ($(this page north west)+(2.5cm,-4cm)$)
    {\blocktitleresult{Results and Benefits}};

    %%% Results and benefices
	% Franklin Gothic book 18 pt
    % line height 135% (line height=1.5x1emx1.35=36.45)
    \node[anchor=north west,tight,color=templateblue,text width=15cm,xshift=1cm,yshift=-0.7cm] (result) at (result title.south west)
    {{\fontsize{18pt}{30pt}\selectfont
	\pgfkeysvalueof{/project/results}\par}
	};
    %%

    \begin{scope}
    \fill[arrowcolor,draw=black] ($(result.south)+(-4cm,-0.5cm)$) -- ($(result.south)+(4cm,-0.5cm)$)
    --  ($(result.south)-(0,1.5cm)$) node (pointe)[anchor=north,scale=2.5,yshift=-0.1cm] 
	{\begin{minipage}{5cm}
	\color{black}
	    \centering\pgfkeysvalueof{/project/contribution}
	\end{minipage}
    } --cycle;
    \end{scope}

    % For the box
    \coordinate (benef NE) at ($(this page north east)+(-3cm,-4cm)$);
    \coordinate (benef SW) at ($(benef NE)-(6.6cm,11 cm)$);
    \coordinate (benef SE) at ($(benef NE)-(0,11 cm)$);

    %% Highlight
    \fill[tight,highlightcolor,opacity=0.4]  (benef SW) rectangle (benef NE);

    % margin of 0.5cm
    % the box is centered
    %
    % The line height is 26pt, as with the \focus command, the text is bigger.
    \node[color=templateblue,font=\highlightfont\fontsize{18pt}{26pt}\selectfont,text width=5.7cm,align=right,tight,highlight style] (benefits) at ($(benef SW)!0.5!(benef NE)$) 
    {
	    \pgfkeysvalueof{/project/highlight}
    };

    %% Info box
    \node[anchor=north east,yshift=-2mm] (info) at (benef SE) {\expandafter\href{\pgfkeysvalueof{/metadata/url}}{\includegraphics[height=1.5cm]{info.png}}};
    \ifdigitaltwin
    \node[anchor=south east] (dt) at (info.south west) {\includegraphics[height=1.5cm]{DT.png}};
    \fi


    % %%% GUIDE
    % \draw[red,thick] (this page north west) -- (this page south east);
    % \draw[red,thick] (this page north east) -- (this page south west);
    % \draw[red,thick] ([xshift=-1cm]this page north east) -- ([xshift=-1cm]this page south east);
    % \foreach \i in {0,1,...,20}
    % {
	% \draw[red,thick] (28.4cm,\i*1cm) -- (29cm,\i*1cm);
    % }


    % Coordinates for academic and industrial partners
    \coordinate (Asw) at ($(this page south west)+(3cm,+1cm)$);
    \coordinate (Ase) at ($(this page south east)+(-3cm,+1cm)$);
    \coordinate (Anw) at ($(this page south west)+(3cm,+4cm)$);
    \coordinate (Ane) at ($(this page south east)+(-3cm,+4cm)$);
    \coordinate (An) at ($(Anw)!0.5!(Ane)$);
    \coordinate (As) at ($(Asw)!0.5!(Ase)$);

    \coordinate (Aw) at ($(Asw)!0.5!(Anw)$);
    \coordinate (Ae) at ($(Ase)!0.5!(Ane)$);

    \coordinate (As academic) at ($(Asw)!0.25!(Ase)$);
    \coordinate (As industrial) at ($(Asw)!0.75!(Ase)$);

    \coordinate (A) at ($(An)!0.5!(As)$);  % middle of the vertical line


    %% Draw the lines for the logos
    \draw (Asw)--(Ase);
    \draw (Anw)--(Ane);
    \draw  (An) -- (As);


%% Place the academic and industrial logos
    \node[anchor=north,yshift=-0.2cm,industrial logo style] (industrial logo) at ($(An)!0.5!(Ane)$) {\industriallogo}; %logo industrial partner
    \node[anchor=north,yshift=-0.2cm,academic logo style] (academic logo) at ($(An)!0.5!(Anw)$) {\academiclogo}; %logo academic partner


%% Name of the academic partner, left 

    \node[tight,academic style] at ($(As academic)+(0,0.75cm)$) 
    {
	\fontsize{18pt}{22pt}\selectfont % Franklin Gothic Book 
	\vphantom{fy}% % for alignment of text
	\color{templatemarroon}\pgfkeysvalueof{/project/academic/name}
    };


%% Description of the industrial partner
    \node[tight,industrial style] at ($(As industrial)+(0,0.75cm)$) 
    {
	\fontsize{18pt}{22pt}\selectfont % Franklin Gothic Book 
	\vphantom{fy}% % for alignment of text
	\color{templatemarroon}\pgfkeysvalueof{/project/industrial/name}
    };

    

\end{tikzpicture}
} % end of the ѕecond page

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TO CREATE THE WHOLE DOCUMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\CreateStory}{
\CreateFirstPage

%\newpage

\CreateSecondPage
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% TYPOGRAPHICAL HELPERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% COMPACT LISTS IN THE TEXT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newlength{\bulletwidth}
\settowidth{\bulletwidth}{\textbullet}
\newenvironment{bullets}{%
\begin{itemize}[noitemsep,topsep=0pt,partopsep=0pt,leftmargin=!,label=\textbullet,labelwidth=\bulletwidth]}%
{\end{itemize}} 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% TO INCREASE THE SIZE OF THE TEXT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%\newcommand{\focus}[1]{\scalebox{1.3}{\bfseries #1}}
\newcommand{\focus}[1]{{\fontsize{23pt}{26pt}\selectfont #1}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% TO INCREASE THE SIZE OF THE TEXT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% changes 0.8 adding some metadata
% changes 0.7 alignement of title and one-line corrected to have similar presentation on the two pages
