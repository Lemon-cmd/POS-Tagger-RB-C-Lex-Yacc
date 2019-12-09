%{

#include "stdio.h"


%}
%token PERIOD COMMA 
%token NOUN PRONOUN VERB ADVERB ADJECTIVE PREPOSITION CONJUNCTION
%token DETERMINER POSS_PRON NOUN_QUAN NOUN_DAY DET_PRON QWORD_PRON AUX_BE AUX_DO
%token AUX_HAVE VERB_BASIC VERB_LIFE VERB_MOTION VERB_OWNERSHIP VERB_CONTAINER
%token VERB_COMMUNICATE VERB_COMMERCE PASTPART 
%token MODAL DET_PRON NOUN_PRON
%token PREP_BASIC PREP

%error-verbose
%%

full : period_sentence { printf("with period \n"); }
	| nonp_sentence { printf("no period \n"); }
;

nonp_sentence : simple_sentence
	      | conj_sentence
;

period_sentence : simple_sentence PERIOD 
		| conj_sentence PERIOD
		| simple_sentence PERIOD simple_sentence
		| simple_sentence PERIOD conj_sentence
		| conj_sentence PERIOD conj_sentence
		| conj_sentence PERIOD simple_sentence
		| PERIOD period_sentence
;

conj_sentence : simple_sentence CONJUNCTION simple_sentence 
	| CONJUNCTION simple_sentence
;

simple_sentence: modal_np verb_phrase 
	| modal_np noun_phrase 
	| modal_np prep_vp 
        | modal_np ADJECTIVE
;

modal_np : conj_np modal
	 | noun_phrase modal
;

conj_np : noun_phrase CONJUNCTION noun_phrase
	| CONJUNCTION noun_phrase	
;

prep_vp : verb_phrase prep verb_phrase
	| prep verb_phrase
	| verb_phrase prep noun_phrase
;

verb_phrase : verb 
	    | verb verb
	    | verb ADJECTIVE
	    | adv_v 
	    | CONJUNCTION verb_phrase
	    | verb_phrase noun_phrase
;


noun_phrase : noun
	    | det noun
       	    | adv_n
	    | det adv_n
            | det ADJECTIVE noun
	    | POSS_PRON noun_phrase
;

adv_v : ADVERB verb
      | verb ADVERB
      ;

adv_n : ADVERB noun
      ;

modal : MODAL
      | aux
;

noun : NOUN_PRON
     | NOUN_QUAN
     | NOUN
;

det : DETERMINER
    | DET_PRON
;

aux : AUX_HAVE
    | AUX_DO
    | AUX_BE
;

verb : VERB
     | VERB_BASIC 
     | VERB_LIFE
     | VERB_MOTION
     | VERB_OWNERSHIP
     | VERB_CONTAINER
     | VERB_COMMUNICATE
     | VERB_COMMERCE
;

prep : PREP
     | PREP_BASIC
;


%%

extern FILE *yyin;
main()
{
	do
	{
		printf("NOUN: %d, VERB: %d ADVERB: %d  ADJ: %d  DETERMINER: %d  AUX_BE: %d PREP_BASIC: %d CONJUNCTION: %d \n", \
		 NOUN, VERB, ADVERB, ADJECTIVE, DETERMINER, AUX_BE, PREP_BASIC, CONJUNCTION);
	
		yyparse();
	}
	while (!feof(yyin));
}

yyerror(s)
char *s;
{
	fprintf(stderr, "%s\n", s);
}
