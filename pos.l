%{
#include "string.h"
#include "y.tab.h"
#define UNKNOWN 0
#include "ctype.h"
#include "stdbool.h"
#define scanstring strlwr(yytext)

int state;
int lookup_word(char *word);
int add_word(int state, char *word);
char *strlwr(char *s);
int noun(char *word);
int adj(char *word);
int adv(char *word);
int verb(char *word);

// Declaring the dictionaries 
%}
%option caseless
suff_s "s"
verb "email"|"add"|"text"|"talk"|"delay"|"discuss"|"append"|"call"|"kill"|"eat"|"exit"|"run"

%%

\n { state = UNKNOWN; return state; }

\.\  |
\.\n { state = PERIOD; add_word(state, yytext); printf("PERIOD\n"); }

[\t\n]+ { state = UNKNOWN; return state; }

\,\n { state = COMMA; printf("COMMA "); return state; }

my |
your |
our |
his | 
her |
their { state = POSS_PRON; add_word(state, yytext); printf("POSS_PRON "); }
                           
this |
that |
these |
those  { state = DET_PRON; add_word(state, yytext); printf("DET_PRON "); }

all |
most |
many |
some |
few |
none |
any { state = NOUN_QUAN; add_word(state, yytext); printf("NOUN_QUAN "); }

who |
which |
that { state = QWORD_PRON; add_word(state, yytext); printf("Q_PRON "); }

am |
is |
are |
was |
were { state = AUX_BE; add_word(state, yytext); printf("MODAL "); }

have |
has |
had { state = AUX_HAVE; add_word(state, yytext); printf("MODAL "); }

made |
chose |
selected { state = VERB_BASIC; add_word(state, yytext); printf("MODAL "); }

ate |
slept |
washed { state = VERB_LIFE; add_word(state, yytext); printf("VERB_LIFE "); }

moved |
stayed |
came |
went |
left |
gone | 
arrived |
departed |
walked |
ran |
flew |
swam |
crawled |
goes | 
dug { state = VERB_MOTION; add_word(state, yytext); printf("VERB_MO "); }

bad |
funny |
happy |
lovely { state = ADJECTIVE; add_word(state, yytext); printf("ADJ "); }

gave |
took |
lent |
borrowed |
bear |
lost |
found { state = VERB_OWNERSHIP;  add_word(state, yytext); printf("VERB_OWN "); }

opened |
closed { state = VERB_CONTAINER; add_word(state, yytext); printf("VERB_CON "); }

said |
told |
emailed |
spoke |
listened { state = VERB_COMMUNICATE; add_word(state, yytext); printf("VERB_COMM "); }

bought |
sold |
rented { state = VERB_COMMERCE; add_word(state, yytext); printf("VERB_C "); }

email |
freeze |
add |
shut |
text |
apologize |
talk |
continue |
delay |
enhance |
discuss |
depend |
run |
close |
call |
ate  |
be |
drink |
get |
keep |
hold |
work |
love |
do |
does |
did |
eat  { state = VERB; add_word(state, yytext); } 

been |
done |
had |
gone { state = PASTPART; add_word(state, yytext); printf("PASTPART "); }

to |
from |
of |
for |
in |
on |
at |
by |
as |
than |
with |
about { state = PREP_BASIC; add_word(state, yytext); printf("PREP_BASIC "); }

near | 
far  |
onto |
into |
through |
across |
inside |
outside |
within |
without | 
above |
below |
over |
under |
underneath |
beneath |
behind |
before |
after |
beyond |
around |
between { state = PREP; add_word(state, yytext); printf("PREP "); }

always |
never |
sometimes |
not |
ever |
there |
somewhere |
very |
here |
away { state = ADVERB; add_word(state, yytext); printf("ADV "); }

can |
could |
may |
might | 
must | 
ought |
shall |
should |
will |
would { state = MODAL; add_word(state, yytext); printf("MODAL "); }

a |
an |
the { state = DETERMINER; add_word(state, yytext); printf("DET "); }

for |
and |
nor |
but |
or |
yet |
so |
because |
however |
although |
despite |
notwithstanding { state = CONJUNCTION; add_word(state, yytext); printf("CONJUNCTION "); }

Chad | 
Zack |
Sam  |
Nick |
horse |
clam  |
John |
Sarah |
Brian |
Dough |
cat   |
dog  |
fish |
food |
day |
year |
month |
church |
thing |
mom |
mother |
father |
dad |
son |
daughter |
grandmother |
grandma |
grandpa |
grandfather |
lion | 
tiger |
girl |
boy |
heart |
nun |
shed |
bird |
butterfly |
sky  { state = NOUN; add_word(state, yytext); printf("NOUN "); }

yesterday |
tomorrow |
today  | 
sunday |
monday |
tuesday |
wednesday |
thursday |
friday |
saturday { state = NOUN_DAY; add_word(state, yytext); printf("NOUN_DAY "); }

i |
you |
he |
she |
it |
we |
us |
they |
them |
him { state = NOUN_PRON; add_word(state, yytext); printf("NOUN_PRON "); }

[a-zA-Z]+ {
        //Scan for words and make sure that it's not a blank
        if (state != UNKNOWN) {
		lookup_word(yytext);
	}
}


%%

struct words {
	//doubly linked list
	char *word_name;
	int word_type;
	struct words *next;
	struct words *prev;
};

struct words *head; /* first element in word list */
struct words *last; 

extern void *malloc() ;

bool isEmpty() {
	//a function for checking if the head of the list is empty
	return head == NULL;
}

char 
*strlwr(char *s) {
	/* Lower the string function */
 	char *p = s;

  	while (*p) {
    		*p = (char) tolower(*p);
    		p++;
  	}

  	return s;
}

int
noun (char *word)
{
	char *last_four, *last_three, *last_two, *last_one;
	int length = strlen(word);
	if (length > 2) {
		last_four = &word[length - 4];
		last_three = &word[length - 3];
		last_two = &word[length - 2];
		last_one = &word[length - 1];
	}else{
		return 0;
	}

	/* Look for NOUN by checking for the last four characters with each suffix */
	char suff_n1[] = "age";
	char suff_n2[] = "ian";
	char suff_n3[] = "ist";
	char suff_n4[] = "ment";
	char suff_n5[] = "or";
	char suff_n6[] = "ty";
	char suff_n7[] = "ism";
	
	if ( strstr(last_three, suff_n1) != NULL || strstr(last_three, suff_n2) != NULL || \
	strstr(last_three, suff_n3) != NULL || strstr(last_four, suff_n4) \ 
	|| strstr(last_two, suff_n5) || isupper(word[0]) != 0 \
	|| strstr(last_two, suff_n6) != NULL || strstr(last_three, suff_n7)) {
		return 1;
	}
	return 0;

}

int 
verb(char *word)
{
	char *last_four, *last_three, *last_two, *last_one;
	int length = strlen(word);
	if (length > 2) {
		last_four = &word[length - 4];
		last_three = &word[length - 3];
		last_two = &word[length - 2];
		last_one = &word[length - 1];
	}else{
	 	return 0;
	}

	char suff_verb[] = "ing";
        char suff_verb1[] = "ate";
        char suff_verb2[] = "ify";
        char suff_verb3[] = "ize";
        char suff_verb4[] = "ise";
        char suff_verb5[] = "en";
	char suff_noun[] = "ent";	
	char suff_verb6[] = "ses";
	
	char suffix_s[] = "s";
	char suffix_verb7[] = "sses";
	char suffix_ed[] = "ed";
	char non_v_suff[] = "ss";
	
	if ( (strstr(last_three, suff_verb) != NULL  || strstr(last_three, suff_verb1) != NULL || \
        strstr(last_three, suff_verb2) != NULL || strstr(last_three, suff_verb3) != NULL \ 
	|| strstr(last_three, suff_verb4) != NULL || strstr(last_three, suff_verb6) != NULL \
        || (strstr(last_two, suff_verb5) != NULL && strstr(last_four, suff_noun) == NULL )) \
	|| (strstr(last_two, non_v_suff) == NULL && strstr(last_one, suffix_s) != NULL ) \
        || (strstr(last_four, suffix_verb7) != NULL ) || (strstr(last_two, suffix_ed) != NULL ))         
        {                
                return 1;
        }                   

	return 0;
}

int 
gerund(char *word)
{
	char  *last_three, *last_two;
	int length = strlen(word);
	if (length > 2) {
		last_three = &word[length - 3];
		last_two = &word[length - 2];
	}else{
	        return 0;
	}

	char gerund[] = "ing";
 	char ed[] = "ed";

	if (strstr(last_three, gerund) != NULL || strstr(last_two, ed) != NULL) {

		return 1;
	}
	return 0;
}

int 
adj(char *word)
{
	char *last_four, *last_three, *last_two, *last_one;
	int length = strlen(word);
	if (length > 2 ) {
		last_four = &word[length - 4];
		last_three = &word[length - 3];
		last_two = &word[length - 2];
		last_one = &word[length - 1];

	}else if (length == 4){
		last_four = word;
	}else{
		return 0;
	}

	char suff_adj1[] = "er";
	char suff_adj2[] = "able";
	char suff_adj3[] = "al";
	char suff_adj4[] = "ful";
	char suff_adj5[] = "ous";
	char suff_adj6[] = "ty"; //tbd
	char suff_adj7[] = "ive";
	char suff_adj8[] = "less";
	char suff_adj9[] = "iest";
	char suff_adj10[] = "est";
	char suff_adj11[] = "ier";	
	
	if ((strstr(last_two, suff_adj1) != NULL || strstr(last_four, suff_adj2) != NULL \  
        || strstr(last_two, suff_adj3) != NULL || strstr(last_three, suff_adj4) != NULL \ 
	|| strstr(last_three, suff_adj5) != NULL || strstr(last_two, suff_adj6) != NULL \
	|| strstr(last_three, suff_adj7) != NULL || strstr(last_four, suff_adj8) !=  NULL \
	|| strstr(last_four, suff_adj9) != NULL || strstr(last_three, suff_adj10) != NULL \
	|| strstr(last_three, suff_adj11) != NULL ) \  
	&& (strstr(last_four, "ever") == NULL) ){
		return 1;
	}
	return 0;

}

int 
adv(char *word)
{
	char *last_four, *last_three, *last_two, *last_one;
	int length = strlen(word);
	if (length > 2) {
		last_four = &word[length - 4];
		last_three = &word[length - 3];
		last_two = &word[length - 2];
		last_one = &word[length - 1];
	}else{
		return 0;
	}


	char suff_adv[] = "ly";
	char suff_adv1[] = "ally";
	char suff_adv2[] = "ily";

	if (strstr(last_two, suff_adv) != NULL || strstr(last_four, suff_adv1) != NULL \ 
	|| strstr(last_three, suff_adv2) != NULL ){
		return 1;
	}
	return 0;

}

int 
there(char *word)
{
	word = strlwr(word);

	if (strcmp(word, "there") == 0){
		return 1;
	}
	return 0;

}

int 
add_word(int type, char *word) 
{
	/* add new word onto the list */
	//create a link
	struct words *wp = (struct words *) malloc(sizeof(struct words));
	//check the prev
	struct words *ptr_prev = last;
   	

	//overwriting the state of the known words in the dictionary;
	
	//first rule: word comes after the, his, her, etc... is declared as noun 		
	if ( (ptr_prev != NULL) && (ptr_prev->word_type == DETERMINER || ptr_prev->word_type == POSS_PRON || ptr_prev->word_type == NOUN_PRON || \
	ptr_prev->word_type == DET_PRON || ptr_prev->word_type == NOUN_QUAN) && \
	(type != ADJECTIVE && type != AUX_BE && type != MODAL && type != NOUN_QUAN) && gerund(word) != 1 ){
		wp->word_type = NOUN;	
	
	//second rule: if the word comes after the, his, her, etc... that is a gerund, adj, or averb, then it is an ADJECTIVE 
	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == DETERMINER || ptr_prev->word_type == NOUN_PRON || ptr_prev->word_type == POSS_PRON || ptr_prev->word_type == DET_PRON) \
	&& (type == VERB || type == ADJECTIVE || gerund(word) == 1 || adj(word) == 1 ) ) {
		wp->word_type = ADJECTIVE;
	
	//third rule: if the word comes after an ADJ or a VERB where it is not a MODAL/AUX_BE/DETERMINER, then it is listed as a noun
	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == ADJECTIVE || ptr_prev->word_type == VERB) && (type != MODAL && type != AUX_BE && type != DETERMINER \
	&& type != POSS_PRON && type != DET_PRON && type != PREP_BASIC && type != PREP && strcmp(ptr_prev->word_name, "be") != 0 && type != ADJECTIVE && type != ADVERB) ) {
		wp->word_type = NOUN;

	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == VERB) && (type == ADJECTIVE || type == ADVERB)) {
		wp->word_type = ADVERB;

	//fourth rule: if the word is after the word be, then it is an ADJECTIVE	
	}else if ((ptr_prev != NULL) && (strcmp(ptr_prev->word_name, "be") == 0) ) {
		wp->word_type = ADJECTIVE;	

	//fifth rule: if the word comes after an ADVERB, then it is a VERB
	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == ADVERB) && type != ADJECTIVE && type != PREP_BASIC && type != CONJUNCTION) {
		wp->word_type = VERB;
	
	//sixth rule: if the word comes after an CONJUNCTION or a PREPOSITION BASIC (to, am, etc...), it is declared as a VERB.
	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == PREP_BASIC || ptr_prev->word_type == CONJUNCTION) \
	&& (type != DETERMINER && type != NOUN && type != NOUN_DAY && type != NOUN_PRON && type != ADVERB && type != NOUN && type != POSS_PRON && type != DET_PRON && type != NOUN_QUAN) ) {
		wp->word_type = VERB;	

	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == PREP_BASIC || ptr_prev->word_type == PREP || ptr_prev->word_type == CONJUNCTION) \
	&& (type != DETERMINER && type != DET_PRON && type != NOUN_PRON && type != POSS_PRON ) ) {
		wp->word_type = NOUN;

	//seventh rule: if the previous word is a noun and the current word is today/yesterday/or any day noun, it is an adv
	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == NOUN) && type == NOUN_DAY) {
		wp->word_type = ADVERB;

	//last rule: if the first word of the input is equal to "there" or the first word after a period is "there", then declared as DET_PRON.
	}else if ( ((ptr_prev == NULL) && (there(word) == 1)) || ( (ptr_prev != NULL) && ptr_prev->word_type == PERIOD && there(word) == 1) ) {
		wp->word_type = DET_PRON;

	//if it doesn't match any rule, don't change the word state.
	}else{
	
		wp->word_type = type;
   	}

	//assign the word onto the list
   	wp->word_name = (char *) malloc(strlen(word)+1);
   	strcpy(wp->word_name, word);
  	
	//print the structure
  	printf("word: %s type: %d | ", word, wp->word_type);

	if(isEmpty()) {
      	//make it the last link
      		last = wp;
   	} else {
      		//make link a new last link
      		last->next = wp;
      		//mark old last node as prev of new link
      		wp->prev = last;
   	}
	
   	last = wp;
	//return the word_type
   	return wp->word_type;
   
}


int
lookup_word(char *word)
{
	/*The LOOKUP function is used to identify UNKNOWN words; any words that are not listed in the dictionary above; */
	
	//if the length of input is not more than 1 character.
	if (strlen(word) <= 1){
		return UNKNOWN;
	}	

	//construct the last state
	struct words *ptr_prev = last;
   		
	//First check for verb, adverb, noun, and adjective
	if (verb(word) == 1){
		add_word(VERB, word);

	}else if (adv(word) == 1){
		add_word(ADVERB, word);

	}else if (adj(word) == 1){
		add_word(ADJECTIVE, word);

	}else if (noun(word) == 1){
		add_word(NOUN, word);
	
	//Check the word using some of the rules delcared in the ADD_WORD function
	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == DETERMINER || ptr_prev->word_type == NOUN_PRON || ptr_prev->word_type == POSS_PRON || ptr_prev->word_type == DET_PRON || ptr_prev->word_type == NOUN_QUAN) ) {
		add_word(NOUN, word);

	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == ADVERB) ) {
		add_word(VERB, word);

	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == AUX_BE ) ) {
		add_word(ADJECTIVE, word);

	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == PREP_BASIC || ptr_prev->word_type == PREP) && isupper(word[0]) != 0) {
		add_word(VERB, word);

	}else if ( (ptr_prev != NULL) && (ptr_prev->word_type == PREP_BASIC || ptr_prev->word_type == PREP) && isupper(word[0]) == 0) {
		add_word(NOUN, word);
		
	}else if ((ptr_prev != NULL) && (strcmp(ptr_prev->word_name, "be") == 0) ) {
		add_word(ADJECTIVE, word);

	}else if ((ptr_prev != NULL) && (ptr_prev->word_type == ADJECTIVE)){
		add_word(NOUN, word);

	}else if ( (ptr_prev == NULL && isupper(word[0]) == 0) || ( ptr_prev != NULL && ptr_prev->word_type == PERIOD && isupper(word[0]) == 0) ){
		add_word(NOUN, word);	
	} 
	
	//Return UNKNOWN; indicating that the word is not recognized.
	return UNKNOWN;

}
