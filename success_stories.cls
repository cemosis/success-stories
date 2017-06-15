%%% Class for compiling success stories.
%%% Author: Antoine Lejay 
%%% Version: 0.2
%%% Date: 2017-02-15

%% This need to be compiled twice, because of the overlay option in tikz.
%% This ensures the good placement on the page.
%% This sould be compiled with *lualatex*
\LoadClass[11pt]{article}
\RequirePackage[T1]{fontenc}
\RequirePackage{cmap}  % for copy and paste unicode characters in pdf
%\RequirePackage[utf8]{inputenc} % no need with lualatex
\RequirePackage{pgfkeys}
\RequirePackage[svgnames]{xcolor}
\RequirePackage[a4paper,landscape]{geometry}
\RequirePackage{pgfkeys}
\RequirePackage{tikz}
\RequirePackage{enumitem}
\RequirePackage{microtype}
\RequirePackage{etoolbox}
%\renewcommand{\familydefault}{\sfdefault}
%\RequirePackage{helvet}
\RequirePackage{ragged2e}
%\usepackage[sfdefault,light,condensed]{roboto} 
\RequirePackage{hyperref}

\usetikzlibrary{calc}
\usetikzlibrary{patterns}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% FONT SPECIFICATION (compile with lualatex)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\usepackage{fontspec}
\setmainfont{Arial Narrow}

\newfontface\thetitlefont{Arial}[LetterSpace=5,WordSpace=2]
\DeclareTextFontCommand\thetitle{\thetitlefont}

\newfontface\theonelinefont{Arial Italic}
\DeclareTextFontCommand\theoneline{\theonelinefont}

\newfontface\blocktitlefont{Arial}[LetterSpace=10,WordSpace=2]
\DeclareTextFontCommand\blocktitle{\blocktitlefont}

\newfontface\blocktitlefontresult{Arial}[LetterSpace=5,WordSpace=1]
\DeclareTextFontCommand\blocktitleresult{\blocktitlefontresult}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PAGE STYLE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\pagestyle{empty}
\setlength{\parindent}{0pt}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% COLORS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\definecolor{templateblue}{HTML}{71b5a5}
\definecolor{templatemarroon}{HTML}{897c57}
\definecolor{highlightcolor}{HTML}{d4eaeb}
\definecolor{arrowcolor}{HTML}{0365c0}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% METADATA 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\pgfkeys{/metadata/.cd,
    author/.initial={[auteurs]},
    date/.initial={0000-00-00},
    keywords/.initial={},
}

\newcommand{\MetaData}[1]{
    \pgfkeys{/metadata/.cd,#1}
}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% KEYS DEFINITION
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

%% Undefined logo
\def\logodefault{\begin{tikzpicture}\draw (0,0) rectangle (1.5cm,1.5cm);
	\draw (0,0) -- (1.5cm,1.5cm); \draw (0,1.5cm) -- (1.5cm,0);\end{tikzpicture}}

%% Logo for the industrial partnership
\let\industriallogo=\logodefault
\pgfkeys{/project/industrial/logo/.code={%
	\ifstrempty{#1}{\let\industriallogo=\logodefault}%
	{\def\industriallogo{\includegraphics[height=1.5cm]{#1}}}%
    }}
%% Logo for the industrial partnership
\let\academiclogo=\logodefault
\pgfkeys{/project/academic/logo/.code={%
	\ifstrempty{#1}{\let\academiclogo=\logodefault}%
	{\def\academiclogo{\includegraphics[height=1.5cm]{#1}}}%
    }}

%% Box for the illustration by default
\def\illustrationdefault{\begin{tikzpicture}\draw (0,0) rectangle (3cm,3cm);
	\draw (0,0) -- (3cm,3cm); \draw (0,3cm) -- (3cm,0);\end{tikzpicture}}

\def\illustrationheight{3cm}
\pgfkeys{
    /project/illustration/height/.store in=\illustrationheight,
    /project/illustration/img/.code={%
	\ifstrempty{#1}{\let\illustration=\illustrationdefault}%
	{\def\illustration{\includegraphics[height=\illustrationheight]{#1}}}%
    }}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% For compact lists
\newlength{\bulletwidth}
\settowidth{\bulletwidth}{\textbullet}
\newenvironment{bullets}{%
\begin{itemize}[noitemsep,topsep=0pt,partopsep=0pt,leftmargin=!,label=\textbullet,labelwidth=\bulletwidth]}%
{\end{itemize}} 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% To set up the content
\newcommand{\Setup}[1]{
\pgfkeys{/project/.cd,#1}
}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The  improve the size of the text
\newcommand{\focus}[1]{\scalebox{1.3}{\bfseries #1}}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For the titles of the blocks
\tikzset{block title/.style={inner sep=0pt,outer sep=0pt,yscale=1.2,color=templateblue,align=left}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% First page
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\CreateFirstPage}{

\begin{tikzpicture}[remember picture,overlay,every node/.style={outer sep=0pt},]

    % Name of the project
    \node[anchor=north,scale=3,inner sep=0pt,color=templatemarroon] (main) at ($(current page.north)-(0cm,0.3cm)$)
	{\thetitle{ \pgfkeysvalueof{/project/name} }};

    % One line description
    \node[anchor=north west,scale=1.8,color=templateblue] (desc) at (main.south west)
	{ \theoneline{ \pgfkeysvalueof{/project/oneline} }};

    \path let \p1=(desc.south),\p2=(current page.east) in node[anchor=north east,yshift=-0.5cm,xshift=-1cm,scale=1.3,color=templatemarroon] (h2020) at (\x2,\y1)
    { H2020 SOCIETAL CHALLENGES: \pgfkeysvalueof{/project/h2020} };

    \path let \p1=(h2020.south),\p2=(current page.east) in node[anchor=north east,yshift=-0.5cm,xshift=-1cm,scale=1.3,color=templatemarroon] at (\x2,\y1)
    { PRODUCTIVE SECTOR:  \pgfkeysvalueof{/project/sector}};


    \node[anchor=north east,xshift=-1cm,scale=1.3] at ($(current page.south east)+(0,15cm)$)
    {
    \begin{minipage}{14.5cm}

	\tikz \node[block title]{\blocktitle{MATHEMATICAL AND COMPUTATIONAL METHODS}};

    \smallskip
    \RaggedRight

	\color{templatemarroon}
	\pgfkeysvalueof{/project/math description}

    \bigskip

	\centerline{\illustration}

    \end{minipage}
    };

    \node[anchor=north west,xshift=1cm,scale=1.3] (probl desc) at ($(current page.south west)+(0,15cm)$)
    {\begin{minipage}{5.5cm}
	\tikz \node[block title]{\blocktitle{PROBLEM}\\ \blocktitle{DESCRIPTION}};

    \smallskip
    
	\color{templatemarroon}
	\pgfkeysvalueof{/project/problem description}
    \end{minipage}
    };

    % challenges and goals
    \node[anchor=north west,scale=1.3,yshift=-0.2cm] at (probl desc.south west)
    {
    \begin{minipage}{5.5cm}
\tikz \node[block title]{\blocktitle{CHALLENGES}\\ \blocktitle{AND GOALS}};

    \smallskip
\RaggedRight

	\color{templatemarroon}
	\pgfkeysvalueof{/project/goal}
    \end{minipage}
    };
\end{tikzpicture}
}
%% / end of CreateFirstPage

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create Second Page
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newcommand{\CreateSecondPage}{
\begin{tikzpicture}[remember picture,overlay,every node/.style={outer sep=0pt}]

    \node[anchor=north,scale=3,inner sep=0pt,color=templatemarroon] (main) at ($(current page.north)-(0cm,0.5cm)$)
	{ \thetitle{\pgfkeysvalueof{/project/name}} };

    \node[anchor=north west,scale=1.8,color=templateblue] (desc) at (main.south west)
	{ \theonelinefont{\pgfkeysvalueof{/project/oneline}} };

%%% Results and benefices
    \node[anchor=north west,xshift=2cm,scale=1.3] (result) at ($(current page.south west)+(0,17cm)$)
    {
    \begin{minipage}{13cm}

   \noindent \tikz \node[xscale=2.5,yscale=2.5,inner sep=0,outer sep=0,color=templatemarroon] {\blocktitleresult{Results and Benefits}};

\medskip\large
	\color{templateblue}
	\pgfkeysvalueof{/project/results}
    \end{minipage}
    };
    %%

    \begin{scope}
    \fill[arrowcolor,draw=black] ($(result.south)+(-4cm,-0.5cm)$) -- ($(result.south)+(4cm,-0.5cm)$)
    --  ($(result.south)-(0,1.5cm)$) node (pointe)[anchor=north,scale=2.5,yshift=-0.1cm] 
	{\begin{minipage}{5cm}
\bfseries\color{black}
	    \centering\pgfkeysvalueof{/project/contribution}
	\end{minipage}
    } --cycle;
    \end{scope}

    % For the box
    \coordinate (benef1) at ($(current page.south east)+(-2cm,16cm)$);
    \coordinate (benef2) at ($(current page.south east)+(-10cm,6cm)$);

    \fill[highlightcolor,opacity=0.4]  (benef1) rectangle (benef2);

    \node[scale=1.5] at ($(benef1)!0.5!(benef2)$) 
    {
	\begin{minipage}{4cm}\color{templateblue}
    \bfseries
\FlushRight
	    \pgfkeysvalueof{/project/highlight}
	\end{minipage}
    };


    \coordinate (Asw) at ($(current page.south west)+(2cm,+0.5cm)$);
    \coordinate (Ase) at ($(current page.south east)+(-2cm,+0.5cm)$);
    \coordinate (Anw) at ($(current page.south west)+(2cm,+4.5cm)$);
    \coordinate (Ane) at ($(current page.south east)+(-2cm,+4.5cm)$);
    \coordinate (An) at ($(Anw)!0.5!(Ane)$);
    \coordinate (As) at ($(Asw)!0.5!(Ase)$);

    \coordinate (Aw) at ($(Asw)!0.5!(Anw)$);
    \coordinate (Ae) at ($(Ase)!0.5!(Ane)$);

    \coordinate (A) at ($(An)!0.5!(As)$);  % middle of the vertical line


%% Draw the lines for the logos
    \draw (Asw)--(Ase);
    \draw (Anw)--(Ane);
    \draw  (An) -- (As);


%% Description of the industrial partner
    \draw let \p1=(An),\p2=(Ane),\n1={0.9*veclen(\x2-\x1,0)} in node[anchor=north east] at (Ae) {
	\begin{minipage}{\n1}
	    \begin{flushright} 
	    \color{templatemarroon} \pgfkeysvalueof{/project/industrial/description}
	\end{flushright}
\end{minipage}
    };

%% Description of the academic partner
    \draw let \p1=(An),\p2=(Anw),\n1={0.9*veclen(\x1-\x2,0)} in node[anchor=north west] at (Aw) {
	\begin{minipage}{\n1}
	    \begin{flushleft} 
		\color{templatemarroon}\pgfkeysvalueof{/project/academic/description}
	\end{flushleft}
\end{minipage}
    };

%% Place the academic and industrial logos
    \node at ($(A)!0.5!(Ane)$) {\industriallogo}; %logo industrial partner
    \node at ($(A)!0.5!(Anw)$) {\academiclogo}; %logo academic partner

    

\end{tikzpicture}
}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
