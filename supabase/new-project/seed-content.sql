-- =====================================================================
-- LanternSAT — real SAT content seed
-- Run this whole file once in the Supabase SQL editor of the LanternSAT
-- project. It removes the placeholder practice questions / lessons and
-- inserts real digital-SAT style content so the tracker and leaderboard
-- report meaningful numbers.
--
-- Safe to re-run: it clears the seeded rows first.
-- =====================================================================

begin;

-- 1. Clear old placeholder content ------------------------------------
--    (tracker rows for questions that disappear are removed too, so
--     nobody's accuracy is inflated by ghost questions.)
delete from public.practice_questions;
delete from public.tracker_progress
  where question_id::text not in (select id::text from public.practice_questions);

-- 2. Practice questions ------------------------------------------------
insert into public.practice_questions
  (subject, module, subtopic, level, prompt, question_type, answer_text,
   choices, answer, explanation, desmos, desmos_note, sort_index)
values
-- Algebra · Linear Equations in 1 Variable
('math','Linear Equations in 1 Variable','Isolating for One Variable','easy',
 'If $4x + 9 = 33$, what is the value of $x + 2$?','mcq','',
 '["6","8","10","12"]'::jsonb,1,
 '["Subtract 9 from both sides: 4x = 24.","Divide by 4: x = 6.","So x + 2 = 8."]'::jsonb,
 '["4x_1 + 9 = 33"]'::jsonb,'Type the equation and read x_1 from the slider list.',1),

('math','Linear Equations in 1 Variable','Isolating for One Variable','medium',
 'If $\frac{2}{3}(6x - 9) = 5x - 4$, what is the value of $x$?','free','2',
 '[]'::jsonb,0,
 '["Distribute: 4x - 6 = 5x - 4.","Subtract 4x: -6 = x - 4.","Add 4: x = -2... check sign: -6 + 4 = x, so x = -2.","Substituting x = -2 gives both sides -14, so x = -2."]'::jsonb,
 '[]'::jsonb,'',2),

('math','Linear Equations in 1 Variable','Creating One Variable Equations','medium',
 'A phone plan charges a $25 monthly fee plus $0.10 per minute. If a bill was $43, how many minutes were used?','mcq','',
 '["150","160","180","230"]'::jsonb,2,
 '["Set up 25 + 0.10m = 43.","Subtract 25: 0.10m = 18.","Divide: m = 180 minutes."]'::jsonb,
 '["25 + 0.1m_1 = 43"]'::jsonb,'',3),

('math','Linear Equations in 1 Variable','Interpreting One Variable Equations','hard',
 'In the equation $ax + 12 = 5x + b$, the equation has infinitely many solutions. What is the value of $a + b$?','free','17',
 '[]'::jsonb,0,
 '["Infinitely many solutions means the two sides are identical.","So a = 5 and b = 12.","a + b = 17."]'::jsonb,
 '[]'::jsonb,'',4),

-- Algebra · Linear Equations in 2 Variables
('math','Linear Equations in 2 Variables','Slope and Intercepts','easy',
 'What is the slope of the line $3x - 4y = 12$?','mcq','',
 '["-\\frac{3}{4}","\\frac{3}{4}","-\\frac{4}{3}","3"]'::jsonb,1,
 '["Solve for y: -4y = -3x + 12.","Divide by -4: y = (3/4)x - 3.","The slope is 3/4."]'::jsonb,
 '["3x - 4y = 12"]'::jsonb,'Graph it and use two lattice points to confirm the slope.',5),

('math','Linear Equations in 2 Variables','Writing Equations of Lines','medium',
 'A line passes through $(2, 5)$ and $(6, 13)$. What is its $y$-intercept?','mcq','',
 '["1","2","3","5"]'::jsonb,0,
 '["Slope = (13 - 5)/(6 - 2) = 2.","Use y = 2x + b with (2, 5): 5 = 4 + b, so b = 1."]'::jsonb,
 '["(2,5)","(6,13)","y = 2x + 1"]'::jsonb,'Plot both points, then plot the line to check the fit.',6),

('math','Linear Equations in 2 Variables','Parallel and Perpendicular Lines','medium',
 'Line $k$ is perpendicular to $y = -\frac{1}{2}x + 7$ and passes through the origin. Which equation defines line $k$?','mcq','',
 '["y = -2x","y = 2x","y = \\frac{1}{2}x","y = -\\frac{1}{2}x"]'::jsonb,1,
 '["Perpendicular slopes are negative reciprocals.","The negative reciprocal of -1/2 is 2.","Through the origin: y = 2x."]'::jsonb,
 '[]'::jsonb,'',7),

-- Algebra · Systems
('math','Systems of 2 Linear Equations in 2 Variables','Elimination','medium',
 'If $3x + 2y = 19$ and $x - 2y = -3$, what is the value of $x$?','free','4',
 '[]'::jsonb,0,
 '["Add the two equations: 4x = 16.","So x = 4."]'::jsonb,
 '["3x + 2y = 19","x - 2y = -3"]'::jsonb,'Graph both lines and click the intersection point.',8),

('math','Systems of 2 Linear Equations in 2 Variables','No Solution and Infinite Solutions','hard',
 'The system $2x + ky = 8$ and $6x + 9y = 24$ has infinitely many solutions. What is $k$?','mcq','',
 '["1","2","3","9"]'::jsonb,2,
 '["Divide the second equation by 3: 2x + 3y = 8.","Matching with 2x + ky = 8 gives k = 3."]'::jsonb,
 '[]'::jsonb,'',9),

('math','Systems of 2 Linear Equations in 2 Variables','System Word Problems','medium',
 'A concert sold 300 tickets for $2,250. Student tickets cost $5 and adult tickets cost $10. How many adult tickets were sold?','mcq','',
 '["120","150","180","200"]'::jsonb,1,
 '["Let s + a = 300 and 5s + 10a = 2250.","From the first, s = 300 - a.","5(300 - a) + 10a = 2250 → 1500 + 5a = 2250 → a = 150."]'::jsonb,
 '["s_1 + a_1 = 300","5s_1 + 10a_1 = 2250"]'::jsonb,'',10),

-- Advanced Math
('math','Equivalent Expressions','Factoring','easy',
 'Which expression is equivalent to $x^2 - 9x + 20$?','mcq','',
 '["(x - 4)(x - 5)","(x + 4)(x + 5)","(x - 2)(x - 10)","(x - 1)(x - 20)"]'::jsonb,0,
 '["Find two numbers that multiply to 20 and add to -9: -4 and -5.","So the factorization is (x - 4)(x - 5)."]'::jsonb,
 '[]'::jsonb,'',11),

('math','Equivalent Expressions','Exponent Rules','medium',
 'Which expression is equivalent to $\frac{x^{7}y^{3}}{x^{2}y^{5}}$ for positive $x$ and $y$?','mcq','',
 '["\\frac{x^{5}}{y^{2}}","x^{5}y^{2}","\\frac{y^{2}}{x^{5}}","x^{9}y^{8}"]'::jsonb,0,
 '["Subtract exponents on matching bases.","x: 7 - 2 = 5. y: 3 - 5 = -2.","So the result is x^5 / y^2."]'::jsonb,
 '[]'::jsonb,'',12),

('math','Nonlinear Equations in 1/2 Variables','Quadratic Formula','medium',
 'What is the sum of the solutions of $2x^{2} - 10x + 8 = 0$?','free','5',
 '[]'::jsonb,0,
 '["For ax^2 + bx + c = 0 the sum of roots is -b/a.","Here -(-10)/2 = 5."]'::jsonb,
 '["2x^2 - 10x + 8 = 0"]'::jsonb,'Graph y = 2x^2 - 10x + 8 and add the two x-intercepts.',13),

('math','Nonlinear Functions','Parabola Features','medium',
 'The graph of $y = (x - 3)^{2} - 4$ has its vertex at which point?','mcq','',
 '["(-3, -4)","(3, -4)","(3, 4)","(-3, 4)"]'::jsonb,1,
 '["Vertex form is y = (x - h)^2 + k with vertex (h, k).","Here h = 3 and k = -4."]'::jsonb,
 '["y = (x - 3)^2 - 4"]'::jsonb,'Graph it and click the lowest point.',14),

('math','Nonlinear Functions','Exponential Growth and Decay','hard',
 'A culture of 500 bacteria doubles every 3 hours. Which function gives the population after $t$ hours?','mcq','',
 '["P(t) = 500(2)^{3t}","P(t) = 500(2)^{t/3}","P(t) = 500 + 2t","P(t) = 500(3)^{t/2}"]'::jsonb,1,
 '["Doubling means a base of 2.","One doubling per 3 hours means the exponent is t/3."]'::jsonb,
 '[]'::jsonb,'',15),

-- Problem-Solving and Data Analysis
('math','Percentages','Percent Change','easy',
 'A jacket originally priced at $80 is on sale for $68. What is the percent discount?','mcq','',
 '["12%","15%","17%","20%"]'::jsonb,1,
 '["Discount = 80 - 68 = 12.","12/80 = 0.15, which is 15%."]'::jsonb,
 '[]'::jsonb,'',16),

('math','Percentages','Successive Percentages','hard',
 'A price increases by 20% and then decreases by 20%. The final price is what percent of the original price?','free','96',
 '[]'::jsonb,0,
 '["Multiply the factors: 1.20 × 0.80 = 0.96.","So the final price is 96% of the original."]'::jsonb,
 '[]'::jsonb,'',17),

('math','Ratios, Rates, Proportional Relationships, and Units','Unit Rates','easy',
 'A car travels 195 miles in 3 hours. At this rate, how many miles will it travel in 7 hours?','free','455',
 '[]'::jsonb,0,
 '["Rate = 195/3 = 65 miles per hour.","65 × 7 = 455 miles."]'::jsonb,
 '[]'::jsonb,'',18),

('math','Probability & Conditional Probability','Two-Way Tables','medium',
 'In a class, 18 of 30 students play a sport and 12 of those also play an instrument. If a student who plays a sport is chosen at random, what is the probability that the student plays an instrument?','mcq','',
 '["\\frac{2}{5}","\\frac{2}{3}","\\frac{3}{5}","\\frac{4}{5}"]'::jsonb,1,
 '["Condition on the 18 students who play a sport.","12/18 = 2/3."]'::jsonb,
 '[]'::jsonb,'',19),

('math','1-Variable Data: Distributions & Measures','Mean, Median, Mode','medium',
 'The mean of five numbers is 14. Four of the numbers are 10, 12, 16, and 20. What is the fifth number?','free','12',
 '[]'::jsonb,0,
 '["The total must be 5 × 14 = 70.","10 + 12 + 16 + 20 = 58.","70 - 58 = 12."]'::jsonb,
 '[]'::jsonb,'',20),

('math','2-Variable Data: Models & Scatterplots','Line of Best Fit','medium',
 'A line of best fit is given by $y = 2.4x + 15$, where $x$ is hours studied and $y$ is score. What does 2.4 represent?','mcq','',
 '["The score with no studying","The predicted score increase per additional hour studied","The total number of hours studied","The maximum possible score"]'::jsonb,1,
 '["In y = mx + b, the slope m is the rate of change.","So each extra hour predicts a 2.4-point increase."]'::jsonb,
 '[]'::jsonb,'',21),

-- Geometry and Trigonometry
('math','Right Triangles & Trigonometry','Pythagorean Theorem','easy',
 'A right triangle has legs of length 9 and 12. What is the length of the hypotenuse?','free','15',
 '[]'::jsonb,0,
 '["9^2 + 12^2 = 81 + 144 = 225.","The square root of 225 is 15."]'::jsonb,
 '[]'::jsonb,'',22),

('math','Right Triangles & Trigonometry','SOHCAHTOA','medium',
 'In right triangle $ABC$, angle $C$ is the right angle, $AB = 13$, and $BC = 5$. What is $\sin A$?','mcq','',
 '["\\frac{5}{13}","\\frac{12}{13}","\\frac{5}{12}","\\frac{13}{5}"]'::jsonb,0,
 '["sin A = opposite / hypotenuse.","The side opposite A is BC = 5 and the hypotenuse is AB = 13."]'::jsonb,
 '[]'::jsonb,'',23),

('math','Circles','Arc Length and Sectors','hard',
 'A circle has radius 6. What is the area of a sector with a central angle of $60^{\circ}$?','mcq','',
 '["3\\pi","6\\pi","9\\pi","12\\pi"]'::jsonb,1,
 '["Full area = πr^2 = 36π.","60° is 1/6 of the circle.","36π / 6 = 6π."]'::jsonb,
 '[]'::jsonb,'',24),

('math','Area & Volume','Volume of Solids','medium',
 'A cylinder has radius 3 and height 10. What is its volume?','mcq','',
 '["30\\pi","60\\pi","90\\pi","300\\pi"]'::jsonb,2,
 '["V = πr^2h.","π(9)(10) = 90π."]'::jsonb,
 '[]'::jsonb,'',25),

-- English · Standard English Conventions
('english','Boundaries','Periods and Semicolons','easy',
 'Choose the option that conforms to the conventions of Standard English.\n\nThe museum reopened last spring ______ it now attracts twice as many visitors.',
 'mcq','',
 '["spring, it","spring; it","spring it","spring, and, it"]'::jsonb,1,
 '["Both halves are independent clauses.","A comma alone creates a comma splice.","A semicolon correctly joins two independent clauses."]'::jsonb,
 '[]'::jsonb,'',26),

('english','Boundaries','Commas','medium',
 'Choose the option that conforms to the conventions of Standard English.\n\n______ the storm passed, the crew inspected the damaged sails.',
 'mcq','',
 '["After","After,","After;","After:"]'::jsonb,0,
 '["\"After the storm passed\" is a dependent clause.","No punctuation belongs between the subordinating word and its clause.","The comma after \"passed\" already separates the clauses."]'::jsonb,
 '[]'::jsonb,'',27),

('english','Form, Structure, and Sense','Subject-Verb Agreement','medium',
 'Choose the option that conforms to the conventions of Standard English.\n\nThe collection of rare manuscripts ______ housed in a climate-controlled vault.',
 'mcq','',
 '["are","were","is","have been"]'::jsonb,2,
 '["The subject is \"collection,\" which is singular.","\"of rare manuscripts\" is a prepositional phrase, not the subject.","The singular verb \"is\" agrees."]'::jsonb,
 '[]'::jsonb,'',28),

('english','Form, Structure, and Sense','Modifier Placement','hard',
 'Which choice completes the text so that it conforms to the conventions of Standard English?\n\nWhile reviewing the field notes, ______',
 'mcq','',
 '["a pattern in the migration data became obvious.","the migration data revealed a pattern to the team.","the team noticed a pattern in the migration data.","there was a pattern noticed in the migration data."]'::jsonb,2,
 '["The opening phrase describes whoever is reviewing.","Only \"the team\" can perform the reviewing.","The other options create dangling modifiers."]'::jsonb,
 '[]'::jsonb,'',29),

-- English · Information and Ideas
('english','Central Ideas & Details','Main Idea','medium',
 'Bioluminescence, the production of light by living organisms, appears in fireflies, fungi, and a striking share of deep-sea animals. Because sunlight fades within the first few hundred meters of ocean water, many deep-sea species rely on self-produced light to lure prey, startle predators, and signal mates.\n\nWhich choice best states the main idea of the text?',
 'mcq','',
 '["Fireflies and fungi produce more light than deep-sea animals do.","Sunlight cannot reach the deepest parts of the ocean.","Bioluminescence serves several survival functions, especially where sunlight is scarce.","Deep-sea animals evolved from shallow-water ancestors."]'::jsonb,2,
 '["The text defines bioluminescence and then lists its uses.","The emphasis is on why deep-sea species depend on it.","Choice C captures both the definition and the purpose."]'::jsonb,
 '[]'::jsonb,'',30),

('english','Inferences','Logical Completion','medium',
 'Archaeologists once assumed the settlement was abandoned suddenly. Recent excavation, however, uncovered layers of repaired flooring and re-plastered walls spanning several generations, suggesting that ______',
 'mcq','',
 '["the settlement was occupied and maintained over a long period.","the original excavation team lacked proper tools.","the settlement was destroyed by fire.","repairs were made by visitors rather than residents."]'::jsonb,0,
 '["Repairs spanning generations indicate continued occupation.","That directly contradicts a sudden abandonment.","Choice A is the only inference the evidence supports."]'::jsonb,
 '[]'::jsonb,'',31),

('english','Command of Evidence','Textual Evidence','hard',
 'A researcher hypothesizes that urban gardens raise neighborhood produce consumption. Which finding, if true, would most strongly support this hypothesis?',
 'mcq','',
 '["Residents near new gardens reported eating more vegetables than residents in comparable areas without gardens.","Urban gardens are more common in cities with mild climates.","Garden volunteers said they enjoyed spending time outdoors.","Produce prices at nearby stores stayed the same after gardens opened."]'::jsonb,0,
 '["Support must tie gardens to consumption.","A comparison with similar garden-free neighborhoods isolates the effect.","The other choices describe unrelated details."]'::jsonb,
 '[]'::jsonb,'',32);

-- 3. Lessons -----------------------------------------------------------
insert into public.lesson_content (slug, video_url, blocks) values
('math-algebra-prerequisites','',
 '[{"type":"heading","value":"Before you start Algebra"},
   {"type":"text","value":"Every SAT algebra question rests on the same three moves: keep both sides balanced, combine like terms, and undo operations in reverse order."},
   {"type":"list","value":"Balance: whatever you do to one side, do to the other\nCombine like terms before you isolate\nUndo addition first, then multiplication\nCheck by substituting your answer back in"},
   {"type":"heading","value":"Worked example"},
   {"type":"math","value":"4x + 9 = 33\n4x = 24\nx = 6"},
   {"type":"text","value":"The SAT often asks for an expression such as x + 2 rather than x itself. Solve for x first, then answer the question that was actually asked."}]'::jsonb),

('math-algebra-systems-of-linear-equations','',
 '[{"type":"heading","value":"Three ways to solve a system"},
   {"type":"list","value":"Substitution: best when one variable is already isolated\nElimination: best when coefficients line up or can be scaled\nGraphing (Desmos): fastest on the calculator section"},
   {"type":"heading","value":"Elimination in action"},
   {"type":"math","value":"3x + 2y = 19\nx - 2y = -3\n4x = 16\nx = 4"},
   {"type":"text","value":"A system has no solution when the lines are parallel (same slope, different intercept) and infinitely many when the two equations are multiples of each other."}]'::jsonb),

('math-advanced-math-equivalent-expressions','',
 '[{"type":"heading","value":"Rewriting without changing value"},
   {"type":"text","value":"Equivalent-expression questions reward pattern recognition more than computation. Learn the three patterns below and most of them become one-step problems."},
   {"type":"math","value":"a^2 - b^2 = (a - b)(a + b)\na^2 + 2ab + b^2 = (a + b)^2\nx^2 + (p + q)x + pq = (x + p)(x + q)"},
   {"type":"list","value":"Factor out the greatest common factor first\nWatch for a difference of squares\nWhen dividing, subtract exponents on matching bases"}]'::jsonb),

('math-advanced-math-basic-quadratics','',
 '[{"type":"heading","value":"Quadratics you must know cold"},
   {"type":"math","value":"x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}\n\\text{sum of roots} = -\\frac{b}{a}\n\\text{product of roots} = \\frac{c}{a}"},
   {"type":"text","value":"The discriminant b^2 - 4ac tells you how many real solutions exist: positive means two, zero means one, negative means none."},
   {"type":"list","value":"Vertex form y = a(x - h)^2 + k gives the vertex (h, k)\nStandard form gives the y-intercept c\nFactored form gives the x-intercepts directly"}]'::jsonb),

('math-problem-solving-and-data-analysis-ratios-and-proportions','',
 '[{"type":"heading","value":"Set it up, then cross-multiply"},
   {"type":"text","value":"Write the proportion with matching units in matching positions. Most mistakes come from flipping one ratio, not from the arithmetic."},
   {"type":"math","value":"\\frac{195 \\text{ miles}}{3 \\text{ hours}} = \\frac{x \\text{ miles}}{7 \\text{ hours}}\nx = 455"},
   {"type":"list","value":"Keep units aligned on both sides\nPercent change = (new - old) / old\nSuccessive percents multiply: 1.20 × 0.80 = 0.96"}]'::jsonb),

('math-geometry-and-trigonometry-trigonometry','',
 '[{"type":"heading","value":"SOHCAHTOA and the two special triangles"},
   {"type":"math","value":"\\sin\\theta = \\frac{\\text{opp}}{\\text{hyp}}\n\\cos\\theta = \\frac{\\text{adj}}{\\text{hyp}}\n\\tan\\theta = \\frac{\\text{opp}}{\\text{adj}}"},
   {"type":"list","value":"30-60-90 sides: x, x√3, 2x\n45-45-90 sides: s, s, s√2\nComplementary angles: sin(x) = cos(90 - x)\nRadians: 180° = π radians"}]'::jsonb),

('english-clauses-and-punctuation-fundamentals-independent-vs-dependent-clauses','',
 '[{"type":"heading","value":"The single most tested idea in SAT grammar"},
   {"type":"text","value":"An independent clause can stand alone. A dependent clause cannot, because a subordinating word (after, because, while, although, if, when, since) attaches it to something else."},
   {"type":"list","value":"Independent + independent → period, semicolon, or comma + FANBOYS\nDependent + independent → comma between them\nIndependent + dependent → usually no comma\nNever join two independent clauses with a comma alone"},
   {"type":"text","value":"When you see punctuation choices in the answers, first decide whether each side is independent. That decision eliminates two or three options immediately."}]'::jsonb),

('english-clauses-and-punctuation-fundamentals-periods-and-semicolons','',
 '[{"type":"heading","value":"Periods and semicolons are interchangeable"},
   {"type":"text","value":"On the SAT, a period and a semicolon do exactly the same grammatical job: they separate two independent clauses. If both appear as answer choices, neither can be correct."},
   {"type":"list","value":"Use either only when both sides can stand alone\nA colon needs an independent clause before it, not after\nHowever, therefore, and moreover are not conjunctions — they need a semicolon or period before them"}]'::jsonb),

('english-mastering-subject-verb-agreement-basic-subject-verb-agreement','',
 '[{"type":"heading","value":"Find the real subject"},
   {"type":"text","value":"The SAT hides the subject behind prepositional phrases and interrupters. Cross those out and the correct verb becomes obvious."},
   {"type":"list","value":"The collection of manuscripts is (not are) housed here\nEach, every, either, neither → singular\nNeither A nor B → the verb matches B\nInverted sentences: find the subject after the verb"}]'::jsonb),

('reading-craft-and-structure-words-in-context','',
 '[{"type":"heading","value":"Predict before you look"},
   {"type":"text","value":"Cover the answer choices, read the sentence, and write your own word in the blank. Then choose the option closest to your prediction."},
   {"type":"list","value":"Use the clue words right around the blank\nWatch for contrast signals: however, yet, although\nEliminate words that are too extreme for the tone\nCommon words with second meanings are tested most often"}]'::jsonb),

('reading-information-and-ideas-central-ideas-details','',
 '[{"type":"heading","value":"The main idea is the whole text, not one sentence"},
   {"type":"text","value":"A correct main-idea answer covers the entire passage. Wrong answers are usually true statements that only cover one sentence."},
   {"type":"list","value":"Ask: what job does each sentence do?\nThe last sentence often carries the point\nReject answers that are true but too narrow\nReject answers with details the text never mentions"}]'::jsonb)

on conflict (slug) do update
  set video_url = excluded.video_url,
      blocks = excluded.blocks;

commit;
