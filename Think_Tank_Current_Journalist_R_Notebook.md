---
title: "Final Journalist File"
output:
  html_document:
    keep_md: TRUE
    df_print: paged
    theme: spacelab
    toc: TRUE
    toc_depth: 2
    toc_float:
      collapsed: FALSE
  editor: visual
---

# Updates

------------------------------------------------------------------------

-   Now using Think Tank Data

-   Randomly 10,000 observations to see how this data set performs

-   Biggest todo I have noticed is to make the code more concise and make it better readable

-   Also really important will be to make the code universal to make it work with any data set.

## Later Todo:

-   Comment the code better
-   Change folder used for the speech files to original hein-daily so others can more easily run and collaborate on code
-   CV.gamlr vs gamlr
-   More dummies at the start of file
-   Cleaner output
-   See which bigrams produced the output
-   See what articles they are

## R Best Practices Now Implemented in this code:

Restarting R instead of rm(list=ls()) command.

-   Clean R session by restarting, instead of clearing variables in an old session
-   *Session \> Restart R* or the associated keyboard shortcut Ctrl+Shift+F10 (Windows and Linux) or Command+Shift+F10 (Mac OS).

Instead of setwd()

-   Using a R project with a folder containing all the files is much more reproducible and easier to share

-   New or Open Project (select a folder)

::Renv to keep track of dependencies:

-   Log all packages used so others can easily load and install the required packages

Below is an article that suggests some best practices for writing code in R:

<https://www.tidyverse.org/blog/2017/12/workflow-vs-script/>

# Setup


```r
# easy loading of packages
library(pacman)
p_load(tidyverse, data.table, tm, quanteda, tokenizers, tidytext, tictoc, gamlr, usethis, Matrix, renv, reactable, easycsv)

# No scientific notation
options(scipen = 100)


# Initialize setting up package dependencies
#renv::init()

# takes a snapshot of package dependencies
renv::snapshot()
```

```
## * Lockfile written to '~/Desktop/Journalist Project - Income Dynamics Lab/renv.lock'.
```

```r
tic("total")

# Generate R file from this R notebook
# knitr::purl("Current_Journalist_R_Notebook.Rmd")
```

# Dummies


```r
# Make y variable a factor or not (Makes no difference)
lasso_y_as_factor = 1

# Speaker or speech level
speaker_level = 1

# Number of files
num_files = 6

# Word Cutoff for the Congressional Speech data i.e. min. number of words in each speech
word_cutoff = 400

# Number of observations used for congress data (needs to be bigger than 3000)
congress_observations = 4000

# Cross_validation?
cross_validated = 1
nfolds_cv = 5

# Number of wapo articles analyzed
wapo_article_size = 100
```

# Load in Think Tank data

### Loading in the Think Tank files for creating the X matrix for the LASSO regression


```r
tic("load speech file")


mypath = "/thinktankdata"

# paste(getwd(),mypath, sep = "")
# 
# all.files <- list.files(path = paste(getwd(),mypath, sep = ""),pattern = ".csv")
# 
# l <- lapply(paste(paste(getwd(),mypath, sep = ""),all.files, sep="/"), fread, sep=",")
# dt <- rbindlist( l )
# setkey( dt , ID, date )
# 
# test <- fread("/Users/max/Desktop/Journalist Project - Income Dynamics Lab/thinktankdata/CATO.csv")

# txt_files_ls <- list.files(path=paste(getwd(), mypath, sep = ""), pattern="*.csv")
# 
# cat("The files used are ", txt_files_ls)
# 
# # Read the files in, assuming comma separator
# txt_files_df <- lapply(txt_files_ls, function(x) {fread(file = txt_files_ls, header = TRUE, sep ="|", quote = "", fill = TRUE)})
# 
# 
# tbl_fread <- 
#     list.files(path=paste(getwd(), mypath, sep = ""), pattern = "*.csv") %>% 
#     map_df(~fread(.))
# 

# USE THIS BELOW!
# df <-
#     list.files(path = "./thinktankdata/",
#                pattern = "*.csv", 
#                full.names = T) %>% 
#     map_df(~read_csv(., col_types = cols(.default = "c")))
# 


dir <- paste(getwd(), "thinktankdata", sep="/")

loadcsv_multi(dir)

CATO$slant <- "R"
`Heritage Foundation`$slant <- "R"

`Center For American Progress Articles new`$slant <- "D"
urban_inst$slant <- 'D'

df <- rbind(CATO, `Center For American Progress Articles new`, `Heritage Foundation`,  urban_inst)
df[!complete.cases(df),]
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["Issue"],"name":[1],"type":["chr"],"align":["left"]},{"label":["Author"],"name":[2],"type":["chr"],"align":["left"]},{"label":["Date"],"name":[3],"type":["chr"],"align":["left"]},{"label":["Content"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Thinktank"],"name":[5],"type":["chr"],"align":["left"]},{"label":["year"],"name":[6],"type":["int"],"align":["right"]},{"label":["art_unique_id"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["slant"],"name":[8],"type":["chr"],"align":["left"]}],"data":[{"1":"TRADE","2":"Mark Nuttle","3":"Jul 16, 1979","4":"(Archived document, may contain errors)46July 16, 1979TRADE AGREEMENTS ACT OF1979 (S-1376-H.R. 4537)BRIEF HISTORY AND DEVELOPING BACKGROUNDFrom independence to approximately 1890 the United States' foreign trade policy was one of revenue-producing tariffs. most laws during this period were amendments or extensions of revenue and protection tariffs and often bordered on conflicts between northern industry and southern agricultural interests. Many of our current tariffs and laws still haunt us today as antiquated, outmoded bureaucratic encumberances that should be removed. In 1890, the McKinley Principal emerged whereby the president was authorized to adjust the tariff scale as a medium of commercial bargaining without prior congressional ratification. After World War I, a surge of protectionist sentiment drove the tariffs up again. The Hawley-Smoot Tariff Act of 1930 was one of the highest tariff laws in the United States history. This tariff signaled an outburst of tariff-making activity around the world, partly by way of reprisal.In the three decades from 1930 to 1958, the United States followed the policy of reciprocal trade. President Roosevelt pushed the Reciprocal Trade Agreements Act of 1934 as part of his New Deal. An amendment to the Hawley-Smoot Tariff Act, the Act permitted the president to enter into trade agreements with other countries by his own signature. Concessions or tariff cutoffs were to be given to foreign countries only in return for conces- sions to the United States.The Reciprocal Trade Agreements Act was renewed 11 times and continued to give increasing powers to the presidency with regard to his capacity to negotiate and set tariff barriers. From 1934 to 1961, the value of American-International Trade increased 15 times as the economy developed, and average U.S. tariffs on dutiable goods dropped 46.7 percent to 12 percent.In 1947, a General Agreement on Tariffs and Trade (GATT) was conducted. This was in part an effort on the part of the United States to ease World War II economic conditions. Twenty-two foreign nations were invited to Geneva to establish GATT legisla- tion. In 1948, the first Republican Congress in 15 years changed the president's powers. A bottom line \"peril point clause\" was included in the Trade Agreements Act requiring a tariff commission to oversee certain limits to which tariffs could drop. The International Trade Organization consisting of 53 nations, includ- ing the U.S., signed an extensive agreement for world trade in 1948. The U.S. Congress never ratified the agreement. In 1949- 1958, the Trade Agreements Act was maintained, restrictions dropped and reenacted, depending upon which political party was in power.In 1962, President Kennedy pursued a trade expansion act. This legislation renewed powers of the president to reduce tariffs, including special authority to deal with the common market goals. From this legislation, the seed was planted that possibly the U.S. should not protect every internal industry.Under the auspices of the GATT, in 1972, a committee was established to prepare for the new round of multilateral trade negotiations with broad focus. Tariff, non-tariff barriers and other measures which impede or distort the U.S.-International trade in both industrial and agricultural products would be examined. The resulting agreements' implementing legislation was the Trade Act of 1974. This Act granted further powers to the presidency to negotiate and reduce tariffs and allowed for the government to enter into agreements for the reduction and elimina- tion of non-tariff barriers, provided implementing legislation was approved by both houses of Congress.With the powers granted by the 1974 Trade Act, the government entered into a multilateral trade negotiations in Geneva, Switzer- land in February 1975. The negotiations are referred to as the Tokyo Round because the results are from the 1973 meeting in Tokyo of the economic administrators of most of the world's nations. Nearly 100 countries have participated in the negotia- tions to date.The Trade Agreements Act of 1979 is the implementing legisla- tion, that must be approved by both houses of Congress, of the finalized, multilateral trade negotiations (The Tokyo Round) conducted by the Ambassador for Special Trade Negotiations over the past four years, and tentatively agreed to by over 80 countries.INTRODUCTIONOn April 12th a \"proces verbal\" was signed by representatives of 98 governments, including the United States. The signing of this accord concluded the active phase and negotiations on most elements of the Multildteral Trade Negotiations. These negotia- tions have been in process since 1973 under the sponsorship of the General Agreement on Tariffs and Trade (GATT). This sets the stage for formal, final closing of the MTN later this year and the implementation of the results of the negotiations beginning in January 1980. The authority by which the United States govern- ment has been involved in the MTN talks was the 1974 Trade Act.The \"proces verbal,\" a diplomatic technique and vehicle used to formally note negotiating results, states that negotiations are completed and that signatories will submit agreements to their domestic approval procedures for:Subsidies and countervailing measures Government procurement Technical barriers to trade Customs evaluation Import and licensing Trade and civil aircraft International trade and procedure Agricultural procedure and framework Meat agreements Dairy agreements Tariff negotiation mechanismsTwo codes which have been subjects of negotiations, safeguards and commerical counterfeiting, have not been completed. Also, not all of the developing countries which participated in the talks have signed the final document. Negotiations will be on-going to encourage those participants to sign as soon as possible this year.- The Tokyo Round of the Multilateral Negotiations, the seventh since World War II, is, by consensus, the most comprehensive since establishment of the International General Agreement on Tariffs and Trade in 1947. For the first time agreements have been concluded which deal with a broad range of so-called non- tariff obstacles to trade, that is, such national government policies and practices as export subsidies, government purchasing requirements, import quotas, and licensing procedures, product standard setting and custom evaluation methods.It is the study of the language in key words in the text of the implementing legislation and the treaty agreement which sheds the most light upon the true meaning and effect of the trade act to the United States for the next 5 to 10 years.MECHANICS OF APPROVAL AND PASSAGEThe package of tariff and non-tariff trade agreements approved by the trade negotiators in Geneva is on an ad referendum basis.Agreements now must be approved finally by the national governments of the signatory or participating nations or, in the case of the nine-nation European Economic Community (EEC), by the EEC Council Administrators as provided by the Treaty of Rome, which establish- ed the European Common Market.The approval process by the United States is described in detail in the Trade Act of 1974. This Act continued the delega- tion of tariff negotiating authority from the Congress to the President. Formal congressional approval of the tariff reductions is not required. However, they will be examined in context of the overall treaty negotiations. Non-tariff agreements must be implemented by the Congress under an expedited legislative process. This process involves the submission of legislation approving the Agreements and making necessary or appropriate changes in domestic law to implement them.The procedures in Senate and House rules for this process are spelled out in the Trade Act. The House and Senate rules setting up these procedures call for a privileged motion to discharge the bill from committees and limitations on debate. They preclude any amendments or parlimentary maneuvers to delay consideration. These rules provide for maximum assurance that the implementing bill will be brought to a straight up or down vote by a simple majority of those present and voting within the time limits stipulated. Under this unique procedure the normal roads to the executive and legislative branches are reserved. The Administration writes one bill to approve the agreements and to make any changes in U.S. law that are necessary or appropriate to implement them. once legislation is introduced, Congress has 90 working days either to veto or approve the bill with no amend- ments. The House takes up the bill first for a maximum of 60 working days. If approved, it will go to the Senate for a maximum of 30 working days.The Trade Agreements Act of 1979 was formally submitted to Congress on June 12. The House passed the measure on July 11 by a vote of 395 - 7. Although the Senate has been expected to consider this before the August recess, it now appears that action may be delayed.GENERAL OVERVIEWThe Tokyo Round of the Multilateral Trade Talks had as its purpose: the establishment of new international rules to assure that trade would be conducted fairly and equitably between nations; to continue the process of reducing specific barriers, both tariff and non-tariff, between individual products; to produce a new set of world trade guidelines to further economic expansion and growth by adding new disciplines designed to keep world commerce fair as well as free.Specific goals to be achieved for the United States by involvement and certain benefits to be derived for the U.S., according to the Administration were:A. The ability of U.S. producers to provide and compete on a non-discriminatory basis for potential lucrative, foreign government procurement contracts;B. A stronger competitive position for U.S. products through international rules limiting government subsidies;C. Greater certainty in exporting resulting from the esta- blishment of uniform and less arbitrary customs valuations systems;D. Procedures to minimize the negative effect on trade of health safety and technical standards;E. An average 33 percent reduction in foreign industrial tariffs; andF. Greater access for U.S. agricultural products in foreign markets from reduced agricultural tariffs and increased quotas.SUBSIDIES AND COUNTERVAILING MEASURES Essentially, the Anti-dumping Act and Countervailing Duty Act will be re-written by this legislation. The use of subsidies has been very harmful on trade production in the United States and other countries. It is widely recognized that all subsidies are employed by the governments to promote important objectives of domestic policy, but any such extension of that policy for international trade is very harmful to the trading partners. A major thrust of the code is, therefore, to control the impact of subsidies on trade flows and international commerce. The Act provides foreign and international rules on the use of countervail- ing duties and other countermeasures to offset the harmful effect of subsidies. A new quasi-judicial system will be enacted whereby an administrative process will be the procedure by which a country may allege that either subsidies or countervailing duties are being unfairly and.illegally applied and receive relief therefrom.Countries adhering to the code will be flatly prohibited from using export subsidies for non-primary industrial products and primary mineral products. It will not now be as important for countries to prove that a subsidy leased at a lower price in overseas markets, therefore allowing for countervailing steps. Should a signatory country be found in violation of these export subsidy obligations, they would become liable for retaliatory countermeasures if the offending practice is not immediately terminated.As currently drafted, the bill provides that the petitioner can allege at any time prior to 20 days before the date of the final determination by the Department of Treasury as to the status of a product that there are political circumstances relat- ing from massive imports of a subsidized merchandise. After the allegation is received, Treasury must determine whether the alleged subsidy is inconsistent with the subsidies-countervailing measures agreement, and whether there have been massive imports of merchandise over relatively short periods of time. The \"criti- cal circumstances\" section now provides guidelines for the use of retroactive suspension and termination of countervailing duties cases. It is expected that critical circumstances will become an issue in virtually all future cases.The major change in the countervailing duty law is a provision of an \"injury standard\" to which signatories to the code have bound themselves. Countervailing duties cannot be applied unless there is a material injury, threat of material injury, or material retardation of the establishment of a domestic industry by reason of imports of that merchandise.Material injury is defined in the bill to be a \"harm which is not inconsequential, immaterial or unimportant.\" This new definition of material injury will be important in future determi- nation tests. The bill also enumerates the criteria that should be considered by the International Trade Commission when making its material injury determination. These factors generally reflect current commission practices under the Anti-dumping Act with regard to agricultural products. The bill states that the mere fact that the prevailing market prices are above minimum support prices is not sufficient to justify a finding of no material injury.Another significant segment and provision of this code is that section regulating the use of internal subsidies. The philosophy of this section was for signatory countries to struc- ture programs which would avoid:A. Causing injury to domestic industries or other signato- ries;B. Nullifying the benefit of their own tariffs and conces- sions through subsidies having import substitution effects;C. Prejudicing the interest of other suppliers to a third country market.Two avenues of redress exist for parties who claim they are being injured by foreign subsidy practices or claim that their internal trading interests are being prejudiced by the payment of foreign subsidies in violation of the agreements' obligations. The first option is domestic action intended to prevent injury to national industries through additional means of countervailing duties. The second option provides a multilateral mechanism through which signatory countries can enforce their rights under the agreement. The second option would be used, for example, when a country is losing a share of a third country market to a subsidized export from another signatory country. The prior U.S. injury test had been exempt from a GATT \"grandfather clause.\" The new agreements will bring the U.S. material injury test into conformity with other international standards.Except in cases involving subsidized imports of duty-free merchandise, current U.S. law does not require finding of injury to a domestic industry prior to the imposition of countervailing duties. Given the codes of discipline or subsidies, the United States will now require an assessment of injuries or threat of injury to a domestic industry before imposing countervailing duties.The second option of countervailing measures will come into play when a country feels that another member's or trading part- ner's subsidies are in violation of the Agreement's provisions. Under these cicumstances, the Agreement provides for mandatory consultations between interested parties. If the parties reach an impasse, then a multilateral dispute settlement committee would hear the disagreement. Ultimately, these procedures could lead to the authorization of countervailing measures against the signatory country found to be in violation of the Agreement.GOVERNMENT PROCUREMENTThe government procurement code is a section by which the chief negotiator, Robert Strauss, and other administrative offi- cials appear to be the most excited. It is claimed that it provides for national treatment and non-discrimation on government purchases. It is the Administration's belief that this code will open up government procurement markets of other countries, which have been largely closed to U.S. producers. These new markets range in scope up to $20 billion annually. The United States will also be required to open its markets to foreign bids on purchases covered by the code. It is true that the U.S. govern- ment's procurement market has been much more open in the past than other countries. Foreign governments have normally bought only from other countries when that good or service was not available domestically. The United States has implemented and applied a \"buy American policy,\" whereby U.S. suppliers were accepted and contracted when their goods were 5-50 percent higher especially in the defense department category. This particular section of the Act covers all contracts valued at $190,000 or more, but does not apply to such things as service contracts, construction contracts, national security items purchased by state or local governments, or purchases by any entity which has not been specified as being covered in the list of specific goods listed in the code. The office of the Special Trade Representa- tive estimates that the code will result in increased U.S. exports of between $1.3 billion and $1.2 billion over the next 3-5 years, for a net gain of 50,000 to 100,000 jobs. Private studies, though, strongly disagree. Private estimates of new jobs have been as low as 15,000.Foreign discrimination against outside producers has been subtle and effective. The code has detailed provisions including obligations to publish invitations to bid, to supply full tender documentation, to apply the same qualification criteria to both domestic and foreign firms, and generally to provide full informa- tion and explanation of every stage of the procurement process.It is the interpretation of the language of the code which will become critical in the near future as to whether or not the signatory countries are actually abiding by the code. The language is very broad and very vague, and as any law subject to interpreta- tion through judicial process, may evolve any number of ways. The judicial process will be the signatory committee making rules and determinations on filed complaints.There are on-going negotiations between the United States and Japan to cover final procurement regulations. The key con- troversial aspects have been the unwillingness of the Japanese to apply the provisions sufficiently to purchases of the Nippon Telephone and Telegraph Corporation. The U.S. and Japanese have reached a tentative agreement. Implementation of joint regulations will be imperative to a final agreement between the United States and Japan.TECHNICAL BARRIERS TO TRADE - THE STANDARDS CODEMany standards, qualifications, labeling requirements, safety regulations, health standards and other such standards regulations have been manipulated and imposed upon U.S. exporters to prohibit the entry of their products into certain foreign countries. Proliferation of such regulations and unfairness in their application have been discriminatory against imports from the United States. The essence of the Agreement on Technical Barriers to Trade is to bring into conformity an international standard on such regulations, thereby diminishing discriminatory and prohibitive product standards. It was the purpose of the United States to advocate open procedures as those used under the Administrative Procedure Act. The bottom line is that imported products are to be treated on the same level as domestic pro- ducts. The Standards Code does not define and distinguish stand- ards for individual products, but again established a quasi- judicial process whereby the signatories may petition for redress upon complaints of the code's violation by other signatories.A committee will review the complaint and may, if a valid complaint remains unsettled, ultimately take steps to rectify the situation or allow for retaliatory action. Such legislation will allow for U.S. exporters to secure reviews of foreign standards and provide the occasion for full-scale federal assistance and involvement in the area of standards and enforcement. Excluded from the Standards Code is any application to services, technical specifications in certain government contracts and standards Bet by private companies for parties other than the government.The bill requires that the Special Trade Representative (STR) coordinate the consideration of, and develop, an inter- national trade policy standards. The STR is also given respon- sibility to coordinate discussions and negotiations with foreign countries for mutual arrangements regarding standards and related activities.The Departments of Commerce and Agriculture are required to establish the technical offices to serve as inquiry points for Anformation regarding U.S. standards, related activities and to perform any other functions the President determines necessary to implement the requirements of this title of the bill. In ad- dition the bill requires that the Department of Commerce maintain a standards information center to serve as the central national coalition collection facility for information on all standards, certifications systems, and standards-related activities world- wide. The center makes this information available to the public where possible.This Trade Act continues and somewhat strengthens the presi- dent's ability to deal with foreign commerce that was established in the Trade Act of 1974. The president is authorized to deny the benefits of Trade Agreement concessions or to improse duties or other imports restrictions in order to enforce the rights of the United States against the products or services of countries, either that have \"most-favored-nation status\" or those that to not have that status.CUSTOMS EVALUATIONThe Customs Evaluation Code addresses the problem of many different, and often arbitrary, national systems for determing how much a product is worth when assessing import and duties. This section of the Act attempts to develop a uniform system which will make it easier to export and make it more difficult for customs authorities to manipulate the customs value to impose a higher duty on U.S. exports.The primary method of evaluation under the code is \"trans- action value,\" which is basing the price actually paid or payable for the importing goods with the additions for costs charges and expenses incurred with respect to imported goods, which are not reflected in the price. A transaction value will be the primary source of evaluation.If a transaction value cannot be used, other systems for determination of value are: identical goods cost; reasonably similar goods cost; the resale price of the particular goods; cost of reproducing the same goods.An administrative procedure is set out for an impartial appeals and establishment of a defined dispute settlement mechan- ism to guard against breaches.IMPORT AND LICENSING CODEThe licensing code and.sections deal with the procedures used in implementing import and licensing systems and attempts to limit the number of forms and approvals that can be required before an exporter can be denied a license, especially on trivial grounds.other requirements listed in the provisions of this code are requirements for:Renewal procedures for obtaining licenses; Publication of the rules governing procedures for applications for import licenses; Limitation of license refusal on minor grounds, including weight, value of commodity, etc.; Specification for financial particulars (foreign exchange) to include the transaction for a license request to be granted.AGREEMENT ON TRADE IN CIVIL AIRCRAFTThe Trade and Civil Aircraft Agreement was initialed by the United States, the European Community, Canada, Japan, Sweden and Norway. The purpose of this section of the overall negotiations was to remove all tariffs from civilian aircraft, aircraft parts and repairs, a market estimated to be $20 billion annually. The United States for many years has maintained a lion's share in the civil aircraft world market. Foreign competitors in the past, however, have been entering the market with increasing success, through subsidies, government financing and non-tariff barriers to imports. An important U.S. objective in the talks has been to halt the proliferation of such government intervention into the free market. The signatories of the multilateral trade talks have in a sense agreed to abide by non-tariff directives in regard to government-directed procurements, offset purchases, susidies, standards and other such restrictions. Key segments of this code include: prohibition of government involvement or coercion in forcing domestic airlines or manufacturers to make purchases from particular, private sources; that the subsidies code applies to trade in civil aircraft, and the determination of any fixed price of civil aircraft , parts and selection of invest- ment; governments are to allow private enterprise to make free choice decisions when purchasing aircraft, parts and selection of suppliers based upon the best price for the best product. Also, the standards code will apply to certification requirements and specfications on operating standards in the civil aeronautics industry. Corresponding to government procurement contracts, qualified firms may be free to accept bids from sub-contractors for the best performance at the best price. Signatories are prohibited from using other government agencies and their powers as part of the purchasing package (i.e. refusing landing rights unless the product is bought from a certain manufacturer).The Agreement on Trade in Civil Aircraft also addresses allowable duties and certain aircraft services and eliminates tariffs on some aircraft engines and parts.The Agreement also provides for the first time for an inter- national forum to settle disputes and to watch developments in the industry in order to head off future conflicts.INTERNATIONAL TRADING FRAMEWORKMany of the negotiating problems or impasses have arisen with regard to less developed countries. In fact, few less developed countries have signed the agreement, and it has become necessary for the U.S. to negotiate with them on a one on one basis. This section of the code deals with the role of develop- ing countries in an international trading system. The \"enabling clause\" provides for a legal basis for deviation to the most- favored-nation principal. Developing countries are held to not seek concessions any greater than those realized under this agreement with other developed countries. It is recognized that as individual developing countries. It is recognized that as individual developing countries progress economically, they will graduate from developing country status and be obliged to partic- ipate more fully in their rights and obligations under the trading system. Further, special benefits would be phased out. Further, the code lists:A measure to correct payment deficits; Agreement concerning safeguard actions for developing purposes; Agreement and understanding regarding notifi- c;ation, consultation of disputed settlements and surveillance (This particular agreement requires GATT members to notify GATT of trade measures which they adopt. This is designed to help sup- ply the signatories with early warning of measures which affect their trade interests); Agreement to reaccess GATT rules on export controls following the multilateral negotiations (ongoing negotiations).This international framework is actually a part of the GATT agreement. It is listed in the front of the 1979 Trade Act bill as an item to be adopted by the U.S. governement.AGRICULTURAL MEASURESThe negotiations in agriculture in the Administration's viewpoint are based on two main objectives: liberalization of barriers to expansion of trade through reduction of tariffs, enlargement or elimination of quantitative restrictions and elimin- ation of health and other restrictions used as trade barriers; and improvements of rules under which trade is carried out through codes of conduct especially with export subsidies and the creation of a framework for exchange of information and discussion.The United States received, in the Administration's opinion, concession in the MTN on agricultural products such as citrus, beef, specialty crops, soybeans, fish, tobacco, fruits and vege- tables, poultry and rice. The United States also made con- cessions in a wide range of agricultural products, especially cheese.A dairy agreement established minimum prices for milk powder, buttermilk fat and cheese. It provides for consultation and exchange of information for further discussions.The subsidies code does apply to agricultural products as does the standards code. If, in fact, these codes can be admin- istered properly, the United States could have the advantages in many agricultural fields. The contrary statements (following in this paper) will point out the language which becomes the pivotal point determining the real benefit of the Trade Act.ENFORCEMENT OF UNITED STATES RIGHTSAs mentioned previously, this section follows the trend set in former Trade Acts of this country and strengthens the office of the presidency with regard to determining retaliatory measures to be used against countries which, in the executive branch's opinion, are violating the agreements.An important point of this part of the bill specifically states that this section is intended to encompass foreign sub- sidies for the construction of vessels used in foreign commerce with the United States. This section could b 'e seen as a warning sign to every major foreign shipbuilder that the United States is very serious about protecting its shipbuilding industry, if in fact, we have a strong president who wants to enforce this sec- tion of the law.Under the administrative hearing process set out in this section, the Special Trade Representative is required to initiate or reject a petition filed under this procedure within 45 days. The STR office must give notice of any action taken and put it in published form in the Federal Register. If an investigation begins, public hearings-are to be held within 30 days, unless the petitioner waives his rights or requests otherwise.Under this administrative operation, the STR must request detailed negotiations with the foreign government concerned. If an agreement or compromise cannot be reached the STR then must proceed under the MTN agreement to present the dispute to a settlement mechanism set out in the agreement. The STR is re- quired to report to Congress on the progress of the hearings. The STR may be required to recommend action to the president.JUDICIAL REVIEWParts of this section of the bill are an amendment to Title 5 of the Tariff Act of 1930 (19 USC 1501 et seq.). This section of the bill sets out the process, timetabl-e and administrative procedure for reviewing petitions, allegations and complaints filed under this Act. Specific guidelines are listed for the International Trade Commission when determining and applying the material injury test, the United States Custom Court when hearing properly filed actions, and the Department of Treasury when executing its administration authority.Definitions are listed in this section for requirements of records at all hearings and what review of those records will encompass.Reviews are allowed to anti-dumping, countervailing duty petitions, standards complaints and other petitions of redress allowed for in this Act.This section of the Act is mainly legal procedure and tech- nical direction for review of complaints. It does illustrate cumbersome entanglements that an industry may be involved with in attempting to have a petition for redress ruled on affirmatively through the appellate process.CONTROVERSIAL CONSIDERATIONS - CAVEATS EXPANDED STRUnder many of the quasi-judicial administrative procedures mechanisms set out in the code for petition and redress, the Special Trade Representative's office received expanded powers in implementing these mechanisms. in many circumstances the STR must act in so many days and make references to the Treasury Department, Department of Commerce and the International Trade Commission. It must make regular reports to the International Trade Commission. It must make regular reports to Congress upon peitions an allegations filed by exporters and make rulings as to the validity of said allegations. This will provide for a much expanded bureaucracy and bureacratic judicial proceeding that could become mammoth.In many instances the STR and other government agencies are not the final say on petitions of redress. The U.S. gives up historical precedent of releasing sovereignty to a committee of signatories to be set up under the Act to make final deter- minations of disputes between member countries. For example, under the subsidies code if the French subsidized wheat to Egypt, the U.S. cannot retaliate immediately. It must go to a signa- tories' committee for approval and that committee has the final say as to whether or not a reprisal is justified.Each code has its own system and procedure for settling dis- putes. In many instances an exporter may first have to handle a domestic bureaucratic entanglement just to face later an inter- national committee and system of like stature.MATERIAL INJURY TESTThe U.S. has adopted a material injury test for countervail- ing duties. The International Trade Commission makes injury determination, but a material injury must be proven. In many instances, injury could be hard to substantiate under current definitions of injury. Prior to this Act, the U.S. government and Congress decided whether countervailing duties were appro- priate and material injury proof was not necessary.GOVERNMENT PROCUREMENTThe Administration openly claims that the treaties nego- tiated access for American companies to foreign government con- tracts. All the language of the agreement says is that American companies will be allowed to bid on projects. It does not necessarily say that the low bid will be taken or that Americans will not be discriminated against once they are in the market. In the United States the precedent and mentality and history is that the low bid wins as long as the low bidder is providing as comparable a product or service as other bidders. Europeans and other countries do it more under the table in that it is not a law or history, but an understanding that a domestic company will receive the contract. The fact that American companies will now be allowed to enter a bid does not by any means mean that they will be able to successfully compete in a discriminatory market.PRESIDENTIAL POWERSThe presidential powers have been increased in this Act for negotiating tariffs and making determinations of what countries should receive counter-reprisals for not following the trade agreement's provisions. Government negotiating powers for tariffs have been increased for five years and for non-tariffs, eight years. Also, this law will require a strong president dedicated to free trade. If the president fails to make quick decisions and take decisive action, a particular industry will be left to the bureacratic administrative hearing procedure which could resultin great time loss.FUTURE OF STRCurrently, the president must make a decision upon recom- mendation as to whether to continue the Special Trade Repre- sentative's office or to establish a Department of Trade. These treaties and agreements.will certainly require one or the other. Ambassador Alan Wm. Wolff, Deputy Special Representative for Trade Negotiations, indicated at a government presentation in the middle of May that the president would make his decision within 90 days after the passage of the 1979 Trade Act. Whether the final result is an expanded STR office or a new Department of Trade, there is little question that a new bureaucracy has sub- stantiated and entrenched itself and will grow even larger in the next 5-10 years, as the administrative process is engaged under this Act.UNCOMPLETED NEGOTIATIONSSeveral sections of the Act will call for further negotia- tions before actual tariff reductions can be made and certain provisions of the agreement executed. Certain signatory coun- tries have refused to set a definite particular as to phasing out certain tariffs and non-tariff barriers. Those time-frames are to be negotiated in the perspective to the current economic world situation as it develops. This means that participating nations could decide to refuse certain tariff reductions in the future, as outlined now.Many of the agreements outlined in the Act are really just goals. They are statements of general philosophy as to what the participating countries would like to see happen in the next 5-10 years. It is not spelled out in detail exactly when various concessions,-if any, will take place by different countries and exactly how some barriers will be changed. They are to be further negotiated. The White House position on the non-specific agreements without timetables is that all participating countries are acting in good faith and that we should trust them.ADMINISTRATIVE PROCEDURESAdministrative law procedure has been discussed by section above; systems have been set up under each code whereby an aggrieved party can petition for relief. Instructions with timetables and guidelines for operation have been listed for the Treasury Department, the U.S. International Trade Commission, and the office of the Special Trade Representative. In many instances, rulings and findings of these U.S. bodies are not final, but are submitted to a committee of signatories, as set out by the Act, to be negotiated and ruled upon by an international tribunal. This administrative process could result in two major developments: increasing release of U.S. sover- eighnty over decision-making in foreign trade; and the establish- ment and growth of a quasi-judicial bureaucracy that could grow to unmanageable proportions.INDEPENDENT PRIVATE STUDIESSeveral private studies were contracted for the Senate Finance Committee. A majority of those studies conclude that the 1979 Trade Act and the MTN negotiations will not have much of a net effect upon the U.S. economy. The bottom line of that con- clusion is that maintaining the status quo may not be that good when, in fact, we are not running at a $30 billion a year deficit.For example, Professor Richardson of Wisconsin in his report, \"Impact on MTN on U.S. Labor,\" states that disadvantaged groups such as women and non-whites will lose some employment. Whites and men will gain some employment. The net change is a minimal positive.The Administration makes too much of the anti-inflation cuts. According to Professor Richardson, 1/10th of 1 percent cut in U.S. cost of living will result, equalling $20 per year per person (aminimal amount).Mr. Don Jackson's study, \"MTN and the Legal Institutions of International Trade,\" states, in short, that the MTN results (of its various codes) will assist in the future balkanization or fragmentation of international trade policies.As Jackson says, there is little consideration given to institutional problems. Confusion could be the new ruling factor of the new regime, for the governing GATT committees. The agree- ments, in effect, create a new, certain number of mini GATTs and and fragments the operation.It is his opinion that there are two ways to pursue inter- national trade policy: one, freer market, less government involve- ment; two, organized free trade through the management/ market approach.The Japanese and the European Community prefer approach number two. The subsidy code leans to number two, also. If, in fact, the Trade Act passes, it is his opinion that there should be a serious reorganization of the executive branch to monitor the new mini GATTs created.Professor Houck's study, \"Tokyo General Round, Relationship to U.S. Agriculture,\" relates that agriculture exports could increase agreements. However, imports will also increase by $106 million and those industries affected will lose 8,000 jobs, primarily in the cheese industry. The net difference is not as substantial as the Administration is predicting (upwards of $1 billion net). An interesting comparison would be what the pro- jections for agriculture imports are under current international law as compared to these projections.A study conducted for the Congressional Research Service by Schnittker and Associates, titled, \"MTN Studies-Result for U.S. Agriculture,\" states that most of our agricultural trade gain comes from concessions in non-tariff trade barriers, mainly in the grain area. The bulk of the U.S. concessions came with the cheese quotas. By 1987 the U.S. could realize $408 million in increased agricultural exports. This amounts to only 2 percent of total exports. Again, the questions becomes, \"could exports gain 2 percent over 8 years without the agreements?\" Other commodities which were projgcted to gain 21 percent over the same period are: almonds, beef, canned peaches, citrus, poultry, rice soybean products, vegetables, protein concentrate.The private studies seem to conclude that the United States has made many specific concessions, especially in the areas of cheese imports, wine gallon vs. proof measures for evaluation, abandonment of American Selling Price System and adoption of the major injury test pursuant to international standards. On the other hand, very few, if any, specific concessions can be pointed to by the other signatories. There is general and vague language about opening up government procurement markets, etc., but nothing specific.If, in fact, there is little or no change as indicated by the private studies in either increased jobs, or exports, or a clear cut market to be pursued by American industry, the Act could help to maintain an international trade deficit in regards to the United States.A private study conducted by two professors from the University of Michigan, Deardorff and Stearn, in summary, says that the agreement will have a minimal effect on our trade deficit. The title of the paper is the \"Economic Analysis of the Effects of the Tokyo Round of MTN on U.S. and Other Major Industrial Countries.\" They say that it is unlikely that the treaty will help labor relocations and will change labor minimally. Reduction in tariffs are larger for the U.S. than the European community or Japan (34.1 percent for the U.S.; 27.8 percent for the EC and 25.3 percent for Japan).Section 2 of the Trade Act of 1974 sets out that the purpose of any future negotiations should be mutually reciprocal in benefits. Private studies in'dicate exactly where our benefits are coming from. Deardorff and Stearn state that the overall effect on employment is to increase employment by 10-15,000, a minimal amount. The New York Times (June 26, 1979) carried the major conclusions oY_thiF-Deardorff and Stearn study, that the agree- ments will have little effect on our trade balance deficit.GOVERNMENT REVENUE LAWSThrough duties to be assessed under the new terms of the agreement, duties projected as income will be less than expected according to private studies: 0.3 billion in 1980; 1.6 billion in 1984. A major concession in this area that the United States made was through the proof method of measuring distilled imports vs. the wine gallon method. The agreement allows for a standard duty on proof of alchol imported, rather than quantity. Before it had been more economical for foreign exporters to send high proof distilled spirits to this country and then have them diluted and bottled here. Now a standard evaluation will be in effect.GENERAL STATEMENTS OF CAVEATSThere is no agreement on the use of safeguards (Article 19 of the GATT) relating to product safety. of course, safety requirements in this country are much more strenuous than others, depending upon the product. Those safeguards are yet to be negotiated.According to private studies, the subsidies agreement were not worked out in enough detail to ensure that certain foreign countries could not get around the subsidies agreement if they wanted to. Again, the general and vague language could mean trouble in the future.A precedent that could be set by this Act is the government participation in civil transactions. As international trade becomes more important to certain industries, government is becoming more and more involved pursuant to the terms of this law. A free enterprise economist would not be happy with increasing government involvement in a growing U.S. market. The long term ramifications could be dangerous.The United States has agreed to abandon the so-called American Selling Price System of customs evaluation on such products as chemicals and rubber-soled footwear. The American Ceiling Price was a major negotiating point for several sessions in Geneva. We have now agreed to a new standard for evaluation of imports.As noted earlier in this paper, the United States Congress in 1948 and since has never ratified the original GATT articles. By accepting many provisions of this bill, Congress will, in effect, by endorsing and adopting the GATT agreements-- specifically by adopting the provision of the bill concerning the framework of the conduct of world trade (in regards to less developed countries, page 10, line 2 of the bill)--be passing into legislation part of the GATT agreements.PRO STATEMENTS - ADVOCATES CONCLUSIONSThe basic conclusions of advocates of the 1979 Trade Act are that the general philosphy and thrust of the purpose of the negotiations as stated in the general overview on each section of the bill were achieved. Advocates hailed the Tokyo Round because it includes non-tariff barriers, claiming that the subsidies code, the import and licensing code, civil aeronairtics codes provide increased advantages for the U.S. industries.The Administration, the Chamber of Commerce of the United States, and the National Association of Manufacturers heartily endorse the Trade Agreements Act of 1979. They believe that the overall Act will be a tremendous boon to U.S. business, especially in the area of government procurements. They state that because-of the Act and the regulations involved therein, U.S. business and companies could realize new markets in upwards of $20-50 billion over the next few years.other claims are: use of subsidies by foreign governments will now be under control; customs evaluation will be uniform and predictable; technical barriers such as licensing and-labeling will be standardized; that even though safeguards were not included in the bill, they will be finalized in the near future. The United States will reduce its tariffs by 31 percent whereby the European Community is reducing its tariffs roughly by 34 percent, Japan will cut its tariffs by 46 percent, claiming that these tariffs reductions will eventually leave the three major trading partners with roughly equivalent tariff levels.The advocates of this bill conclude that the language is specific enough to realize all goals as set out in the agree- ments: that all signatory countries will participate in good faith and that future negotiations on timetables for the phasing in of tariff reducations will be executed as planned, and that all judicial processes set up to review petitions and complaints will be handled efficiently, effectively and in short time with proper justice dealt out on all disputes.CONCLUSIONThe Tokyo Round and MTN documents initialed in Geneva last April are actually a series of agreements on tariffs, code of conduct, non-tariff measures and understandings, standards, cus- toms evaluations, trade policies and administrative processes for governing purposes to be implemented through a domestic and international administrative procedure. The Trade Agreements Act of 1979 is the United States government implementing-legislation to bring the laws into conformity with the negotiations concluded by the Special Trade Representative's office. The bill is com- prehensive, covering many complicated areas of international trade. The U.S. gave a few specific concessions in the areas of cheese imports, wine gallon measures on imports, U.S./American Selling Price Policy Systems and major injury test standards. Our foreign partners have given up questionable concessions in a more general and broad language, some of which are to be stip- ulated upon in further negotiations.The administrative processes set out in the bill for the Department of Treasury, U.S. International Trade Commission and the Special Trade Representative's office will require an increasing bureaucracy to implement and execute the directives over the next 5-10 years.The bottom line concerns by the private studies conducted are that the Trade Act really does not mean anything significant towards denting this country's balance of trade deficits. It will also mean little in new jobs or labor relocation. Also, the broad and general language of the bill require further negotiations that could allow for escape of certain obligations by other signatories in the future as to tariff phase-outs.If the bill means, as the Administration believes, new markets and upwards of billions of dollars for U.S. export companies over the next few years in both agriculture and in industry, the Act could have a favorable effect on this nation's economy in the Act could have a favorable effect on this nation's economy in proceeding years. Much of the Act's benefit will depend upon good faith, unselfish participation by other signatories, efficient execution by the administrative procedure mechanisms, and final, clear determination and definition of the bill's general language.Written at the request of The Heritage-Foundation by R. Marc Nuttle","5":"Heritage Foundation","6":"1979","7":"NA","8":"R","_rn_":"71373"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
df <- df[complete.cases(df),]

rm(CATO)
rm(`Center For American Progress Articles new`)
rm(`Heritage Foundation`)
rm(urban_inst)

df$slant <- factor(df$slant)
# Combine them

#df <- do.call("rbind", lapply(txt_files_df, as.data.frame)) 

# Single file approach
# df <- read.table("/Users/max/Desktop/Journalist Project - Income Dynamics Lab/hein-daily/speeches_114.txt", header=TRUE, sep="|", quote = "", fill = TRUE)

toc()
```

```
## load speech file: 10.431 sec elapsed
```

# Initial Analysis

### Analyze the dataset of speech files


```r
tic("Speech data analysis")

colnames(df)[colnames(df) == 'Content'] <- "speech"
colnames(df)[colnames(df) == 'art_unique_id'] <- "id"
df <- df[complete.cases(df), ]
# find any missing observations
sum(is.na(df))
```

```
## [1] 0
```

```r
# dimensions of the dataframe
dim(df)
```

```
## [1] 78730     8
```

```r
# Find out the number of words of each speech
df$nwords <- str_count(df$speech, "\\w+")
#df$nwords <- sapply(df$speech, function(x) length(unlist(strsplit(as.character(x), "\\W+"))))


cat("The number of speeches with NA as the value is ", sum(is.na(df$nwords)))
```

```
## The number of speeches with NA as the value is  0
```

```r
cat("The number of speeches with 0 words, thus empty is ", length(df$nwords[df$nwords==0]))
```

```
## The number of speeches with 0 words, thus empty is  454
```

```r
as.data.frame(table(cut(df$nwords,breaks=seq(0,2000,by=50))))
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["Var1"],"name":[1],"type":["fct"],"align":["left"]},{"label":["Freq"],"name":[2],"type":["int"],"align":["right"]}],"data":[{"1":"(0,50]","2":"8309"},{"1":"(50,100]","2":"4003"},{"1":"(100,150]","2":"3716"},{"1":"(150,200]","2":"1716"},{"1":"(200,250]","2":"1738"},{"1":"(250,300]","2":"1904"},{"1":"(300,350]","2":"2111"},{"1":"(350,400]","2":"2221"},{"1":"(400,450]","2":"2113"},{"1":"(450,500]","2":"2055"},{"1":"(500,550]","2":"2137"},{"1":"(550,600]","2":"2351"},{"1":"(600,650]","2":"2719"},{"1":"(650,700]","2":"3678"},{"1":"(700,750]","2":"3666"},{"1":"(750,800]","2":"3708"},{"1":"(800,850]","2":"3628"},{"1":"(850,900]","2":"3028"},{"1":"(900,950]","2":"2369"},{"1":"(950,1e+03]","2":"1963"},{"1":"(1e+03,1.05e+03]","2":"1712"},{"1":"(1.05e+03,1.1e+03]","2":"1514"},{"1":"(1.1e+03,1.15e+03]","2":"1255"},{"1":"(1.15e+03,1.2e+03]","2":"1085"},{"1":"(1.2e+03,1.25e+03]","2":"977"},{"1":"(1.25e+03,1.3e+03]","2":"791"},{"1":"(1.3e+03,1.35e+03]","2":"683"},{"1":"(1.35e+03,1.4e+03]","2":"618"},{"1":"(1.4e+03,1.45e+03]","2":"570"},{"1":"(1.45e+03,1.5e+03]","2":"462"},{"1":"(1.5e+03,1.55e+03]","2":"464"},{"1":"(1.55e+03,1.6e+03]","2":"395"},{"1":"(1.6e+03,1.65e+03]","2":"415"},{"1":"(1.65e+03,1.7e+03]","2":"345"},{"1":"(1.7e+03,1.75e+03]","2":"305"},{"1":"(1.75e+03,1.8e+03]","2":"313"},{"1":"(1.8e+03,1.85e+03]","2":"240"},{"1":"(1.85e+03,1.9e+03]","2":"223"},{"1":"(1.9e+03,1.95e+03]","2":"201"},{"1":"(1.95e+03,2e+03]","2":"202"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
summary(df$nwords)
```

```
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##       0     244     677     911     987   53701
```

```r
toc()
```

```
## Speech data analysis: 12.368 sec elapsed
```

Creating a frequency plot


```r
p <- ggplot(df[df$nwords<250,], aes(x = nwords)) +
  geom_freqpoly(bins=50, color = "navyblue") +
  labs(
    title = "Frequency of Think Tank Speech length",
    x = "Number of Words",
    y = "Observations"
  )
rect <- data.frame(xmin=0, xmax=10, ymin=-Inf, ymax=Inf)
pp <- p + geom_rect(data=rect, aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax), color=NA, alpha=0.2, inherit.aes = FALSE)
pp + scale_x_continuous(breaks = seq(0, 100, by = 10))
```

![](Think_Tank_Current_Journalist_R_Notebook_files/figure-html/unnamed-chunk-2-1.png)<!-- -->


```r
# Lets take the 1st quartile as an example (this is something that could be changed)
#df <- df[df$nwords>11,]
df <- df[df$nwords>word_cutoff,]

# Keep number of words as a separate vector when needed
nwords <- df$nwords



# Subset columns only speech_id and speeches
#df <- df[c(4,7)]



#df[!duplicated(df$id), ] 
df <- df[sample(nrow(df),size=15000),] #congress_observations
df$id <- factor(df$id)
```

# Congress Speech Bigram Conversion Pt. 1

These steps are very close to the Stanford/Taddy study and the results obtained are similar when comparing the output files.


```r
tic("bigram conversion - until tokens")
# rename columns in order to put them into a corpus object
colnames(df)[colnames(df) == 'id'] <- "doc_id"
colnames(df)[colnames(df) == 'speech'] <- "text"

df <- df[!duplicated(df$doc_id), ]
# (ii) removing apostrophes and replacing commas and semicolons with periods
## removing apostrophes
df$text <- gsub("'", '', df$text)

# replacing commas and semicolons with periods
df$text <- gsub(",", '.', df$text)
df$text <- gsub(":", '.', df$text)

# (iii) replacing repeated white space characters with a single space (if necessary)
df$text <- str_squish(df$text)

# (iv) removing punctuation—hyphens, periods, and asterisks—that separate the article’s demarcation from the actual article
df$text <- gsub('"', '', df$text)
df$text <- gsub('.', '', df$text, fixed = TRUE)
df$text <- gsub('*', '', df$text)
df$text <- gsub('-', '', df$text)
df$text <- gsub('_', '', df$text)

# STEP V removing white spaces at the beginning and end of the speeches
# removes leading and trailing white spaces from the character vectors a.k.a the speeches
df <- df %>% 
  mutate(across(where(is.character), str_trim))

corpus <- corpus(df)
tokenz <- tokenizers::tokenize_words(corpus, lowercase = TRUE,) %>%
  tokens(what = "word",remove_punct = TRUE, remove_symbols = TRUE, remove_numbers = FALSE, remove_url = TRUE, remove_separators = TRUE, split_hyphens = TRUE, include_docvars = TRUE, padding = TRUE, verbose = quanteda_options("verbose"), )

toc()
```

```
## bigram conversion - until tokens: 81.557 sec elapsed
```

# Congress Speech Bigram Conversion Pt. 2


```r
tic("bigram conversion - finished")
tokenz[3]
```

```
## Tokens consisting of 1 document.
## 12694 :
##  [1] "as"          "the"         "sixth"       "anniversary" "of"         
##  [6] "september"   "11"          "approaches"  "the"         "american"   
## [11] "public"      "and"        
## [ ... and 719 more ]
```

```r
tokenz <- tokens_remove(tokenz, pattern = stopwords("en"))
tokenz[3]
```

```
## Tokens consisting of 1 document.
## 12694 :
##  [1] "sixth"        "anniversary"  "september"    "11"           "approaches"  
##  [6] "american"     "public"       "policymakers" "focused"      "upcoming"    
## [11] "general"      "petraeus"    
## [ ... and 417 more ]
```

```r
tokenz <- tokens_wordstem(tokenz, language = "en")
tokenz[3]
```

```
## Tokens consisting of 1 document.
## 12694 :
##  [1] "sixth"       "anniversari" "septemb"     "11"          "approach"   
##  [6] "american"    "public"      "policymak"   "focus"       "upcom"      
## [11] "general"     "petraeus"   
## [ ... and 417 more ]
```

```r
toks_ngram <- tokens_ngrams(tokenz, n = 2, concatenator = " ")

toks_dfm <- dfm(toks_ngram)

x <- tidytext::tidy(toks_dfm)
colnames(x)[colnames(x) == 'document'] <- "speech_id"

# mypath = "/Users/max/Desktop/Journalist Project - Income Dynamics Lab/hein-daily/"
# txt_files_ls <- tail(list.files(path="/Users/max/Desktop/Journalist Project - Income Dynamics Lab/hein-daily/", pattern="SpeakerMap.txt"), num_files)
# 
# cat("The files used are ", txt_files_ls)
# 
# # Read the files in, assuming comma separator
# txt_files_df <- lapply(txt_files_ls, function(x) {read.table(file = paste(mypath,x, sep = ""), header = TRUE, sep ="|")})
# # Combine them
# 
# speaker_map <- do.call("rbind", lapply(txt_files_df, as.data.frame)) 
# 
# # speaker_map <- read.csv("/Users/max/Desktop/Journalist Project - Income Dynamics Lab/hein-daily/114_SpeakerMap.txt", header = TRUE, sep = "|")
# DF <-merge(x=DF,y=speaker_map,by="speech_id",all.x=TRUE)
# #DF <- DF[c(1:4)]


x <- x %>%
  group_by(speech_id, term) %>%
  summarise(Frequency = sum(count))
```

```
## `summarise()` has grouped output by 'speech_id'. You can override using the
## `.groups` argument.
```

```r
x <- x[complete.cases(x),]
head(x)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["speech_id"],"name":[1],"type":["chr"],"align":["left"]},{"label":["term"],"name":[2],"type":["chr"],"align":["left"]},{"label":["Frequency"],"name":[3],"type":["dbl"],"align":["right"]}],"data":[{"1":"10001","2":"2013 attack","3":"1"},{"1":"10001","2":"2013 candid","3":"1"},{"1":"10001","2":"2017 commentari","3":"1"},{"1":"10001","2":"2017 share","3":"1"},{"1":"10001","2":"9 2017","3":"2"},{"1":"10001","2":"acclaim bomb","3":"1"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
toc()
```

```
## bigram conversion - finished: 179.741 sec elapsed
```


```r
df2 <- df[c(7,8)]
colnames(df2)[colnames(df2) == 'doc_id'] <- "speech_id"
df2$speech_id <- as.character(df2$speech_id)
byspeaker <- left_join(x, df2, by="speech_id")
```

The code chunk above shows that we have successfully created a factor with more levels by using speech_id instead of speaker id

# Creating Sparse Matrix


```r
colnames(byspeaker)[colnames(byspeaker) == 'speech_id'] <- "speakerid"
colnames(byspeaker)[colnames(byspeaker) == 'term'] <- "phrase"
colnames(byspeaker)[colnames(byspeaker) == 'Frequency'] <- "count"



# byspeaker$unique_speech_id <- make.unique(as.character(byspeaker$speech_id) ,sep = ".")
# byspeaker <- byspeaker[order(byspeaker$unique_speech_id),]

# byspeaker$unique_speech_id <- paste("ID", byspeaker$unique_speech_id)
# byspeaker$unique_speech_id <- factor(byspeaker$unique_speech_id)
# byspeaker <- byspeaker[order(byspeaker$unique_speech_id),]
# byspeaker$phrase <- factor(byspeaker$phrase)


# X <- sparseMatrix(i = as.numeric(byspeaker$unique_speech_id), j = as.numeric(byspeaker$phrase), x = byspeaker$count, dims = c(nlevels(byspeaker$unique_speech_id), nlevels(byspeaker$phrase)), dimnames = list(id=levels(byspeaker$unique_speech_id), phrase=levels(byspeaker$phrase)))

# X <- sparseMatrix(i = as.numeric(byspeaker$unique_speech_id), j = as.numeric(byspeaker$phrase), x = byspeaker$count, dims = c(nlevels(byspeaker$unique_speech_id), nlevels(byspeaker$phrase)), dimnames = list(id=levels(byspeaker$unique_speech_id), phrase=levels(byspeaker$phrase)))

#byspeaker <- byspeaker[complete.cases(byspeaker), ]

# create sparse matrix
byspeaker <- byspeaker[order(byspeaker$speakerid),]
byspeaker$speakerid <- factor(byspeaker$speakerid)
byspeaker$phrase <- factor(byspeaker$phrase)

X <- sparseMatrix(i = as.numeric(byspeaker$speakerid), j = as.numeric(byspeaker$phrase), x = byspeaker$count, dims = c(nlevels(byspeaker$speakerid), nlevels(byspeaker$phrase)), dimnames = list(id=levels(byspeaker$speakerid), phrase=levels(byspeaker$phrase)))

# speakermap <- read.table("hein-daily/114_SpeakerMap.txt", sep="|", header=T)
# speakermap <- speaker_map
# 
# speakermap$name <- paste(speakermap$firstname, speakermap$lastname) # one name
# speakermap <- speakermap[!duplicated(speakermap$speakerid),c("speakerid","party", "name")] # drop irrelevant cols
#byspeaker <- byspeaker[order(byspeaker[,1]),] # sort by id
# 
# # drop ids not in X
byspeaker2 <- byspeaker
drop_these_ids <- as.integer(setdiff(as.character(byspeaker$speakerid),row.names(X)))
byspeaker <- byspeaker[!(byspeaker$speakerid %in% drop_these_ids),]



byspeaker <- byspeaker[!duplicated(byspeaker$speakerid),]

# check that ids in X and speakermap line up
if (sum(!(row.names(X)==as.character(byspeaker$speakerid))) != 0) { print("Recheck code: ids are not aligned.")}


print(object.size(X),units="auto")
```

```
## 408.5 Mb
```

```r
dim(X)
```

```
## [1]   13093 4066456
```

```r
matrixplot <- image(X)

matrixplot
```

![](Think_Tank_Current_Journalist_R_Notebook_files/figure-html/construct x matrix-1.png)<!-- -->

```r
# Zoomed in version
image(X[1:400,1:400])
```

![](Think_Tank_Current_Journalist_R_Notebook_files/figure-html/construct x matrix-2.png)<!-- -->

```r
# byspeaker$paste <- factor(paste(byspeaker$speech_id, byspeaker$phrase))
# X_test2 <- sparseMatrix(i = as.numeric(byspeaker$paste), j = as.numeric(byspeaker$phrase), x = byspeaker$count, dims = c(nlevels(byspeaker$paste), nlevels(byspeaker$phrase)), dimnames = list(id=levels(byspeaker$paste), phrase=levels(byspeaker$phrase)))
# 


# check that it worked
byspeaker[1:5,]
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["speakerid"],"name":[1],"type":["fct"],"align":["left"]},{"label":["phrase"],"name":[2],"type":["fct"],"align":["left"]},{"label":["count"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["slant"],"name":[4],"type":["fct"],"align":["left"]}],"data":[{"1":"10001","2":"2013 attack","3":"1","4":"R"},{"1":"10002","2":"10 percent","3":"1","4":"R"},{"1":"10006","2":"10000arrest mani","3":"1","4":"R"},{"1":"10008","2":"2013 look","3":"1","4":"R"},{"1":"10009","2":"70 yearslong","3":"1","4":"R"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
X[1,as.numeric(byspeaker$phrase)[1:5]]
```

```
##      2013 attack       10 percent 10000arrest mani        2013 look 
##                1                0                0                0 
##     70 yearslong 
##                0
```

```r
#rm(byspeaker)


# speakermap <- read.table("hein-daily/114_SpeakerMap.txt", sep="|", header=T)


# speakermap <- speaker_map
# 
# 
# 
# speakermap$name <- paste(speakermap$firstname, speakermap$lastname) # one name
# speakermap <- speakermap[!duplicated(speakermap$speakerid),c("speakerid","party", "name")] # drop irrelevant cols
# speakermap <- speakermap[order(speakermap[,1]),] # sort by id

# drop ids not in X
# drop_these_ids <- as.integer(setdiff(as.character(factor(byspeaker$unique_speech_id)),row.names(X)))
# byspeaker <- byspeaker[!(byspeaker$speakerid %in% drop_these_ids),]
# 
# # Merge to have a speaker id for each speech_id
# 
# # check that ids in X and speakermap line up
# if (sum(!(row.names(X)==as.character(factor(byspeaker$unique_speech_id)))) != 0) { print("Recheck code: ids are not aligned.")}
```


```r
# Bernie Sanders and Angus King both seem to be Democrat leaning thus we will change their values to D
# byspeaker$party[byspeaker$name == "BERNARD SANDERS"] <-"D"
# byspeaker$party[byspeaker$name == "ANGUS KING"] <-"D"
# byspeaker$party[byspeaker$name == "GREGORIO SABLAN"] <-"D"
# # This can be checked later to see if there are any other congressmen that need to be recoded in terms of their political party
# byspeaker$party[byspeaker$party == "I"] <-"D"
# #speakermap$party <- factor(speakermap$party)
# table(byspeaker$party)
# 
# # lasso with raw counts
# if (lasso_y_as_factor == 0) {
# cat(" ")
# cat(" ")
# cat("Party variable will be converted to factor")
# cat(" ")
# cat(" ")
# byspeaker$party <- factor(byspeaker$party)
# head(byspeaker$party)
# } else {
# byspeaker$party <- ifelse(byspeaker$party == "R", 1,0)
# cat(" ")
# cat(" ")
# cat("Manually coded for R = 1 and D = 0")
# cat(" ")
# cat(" ")
# head(byspeaker$party)
# }
# 
# str(byspeaker)
```

# Cross-Validated LASSO Regression

# R = 1, D = 0


```r
# y <- speakermap$party
byspeaker$slant <- ifelse(byspeaker$slant == "R", 1,0)
y <- byspeaker$slant

if (cross_validated==1) {
lassoslant <- cv.gamlr(X,y, nfold = 5, verb = TRUE , select="1se") #nfolds_cv as nfold arg
plot(lassoslant)
B <- coef(lassoslant, select="1se")[-1, ]
cat("Using cv.gamlr function with cross-validation")
} else {
lassoslant <- gamlr(X, y) # use AICc for speed
plot(lassoslant)
B <- coef(lassoslant)[-1, ]
cat("Using gamlr function with AICc (no cross-validation)")
}
```

```
## fold 1,2,3,4,5,done.
```

```
## Using cv.gamlr function with cross-validation
```

```r
#lassoslant <- gamlr(X, y) # use AICc for speed
#lassoslant <- cv.gamlr(X,y, nfold = nfolds_cv, verb = TRUE , select="1se")
plot(lassoslant)
```

![](Think_Tank_Current_Journalist_R_Notebook_files/figure-html/lasso-1.png)<!-- -->

```r
B <- coef(lassoslant)[-1, ] #, select="1se"
head(sort(round(B[B != 0], 4))) # nonzero coefficients
```

```
##  american progressse    american progress american progressmor 
##              -0.5083              -0.4330              -0.4321 
## american progressfor        rang institut           still sore 
##              -0.4319              -0.3911              -0.3235
```

```r
tail(sort(round(B[B != 0], 4)))
```

```
##                  overal percentag                      driven solut 
##                            0.2499                            0.2988 
##                      pollut futur americanprogressorgcarolin wadham 
##                            0.3525                            0.3538 
##             address infrastructur                           08 sign 
##                            0.4428                            1.1536
```

```r
coefficients_lasso2 <- data.frame(as.list(sort(round(B[B != 0], 4)))) # nonzero coefficients
#write.csv(coefficients_lasso2, file ="/Users/max/Desktop/Journalist Project - Income Dynamics Lab/lasso_coefficients.csv")
names(sort(B)[1:10]) # Low repshare (Dems)
```

```
##  [1] "american progressse"  "american progress"    "american progressmor"
##  [4] "american progressfor" "rang institut"        "still sore"          
##  [7] "peopl employerprovid" "independ global"      "damag disast"        
## [10] "baptist associ"
```

```r
names(sort(-B)[1:10]) # High repshare (Repubs)
```

```
##  [1] "08 sign"                           "address infrastructur"            
##  [3] "americanprogressorgcarolin wadham" "pollut futur"                     
##  [5] "driven solut"                      "overal percentag"                 
##  [7] "100 billssh"                       "11 levelsprocur"                  
##  [9] "diploma drop"                      "posit number"
```

```r
# lasso with proportions
x_prop <- X/rowSums(X)
lassoslant_prop <- gamlr(x_prop, y)
B_prop <- coef(lassoslant_prop)[-1, ]
head(sort(round(B_prop[B_prop != 0], 4)))
```

```
## progress compil    anybodi know     hart polici       reign god   fall familiar 
##       -970.6311       -629.7201       -625.7097       -623.0270       -558.1478 
##   declar failur 
##       -537.1401
```

```r
head(names(sort(B_prop)[1:10])) # Low repshare (Dems)
```

```
## [1] "progress compil" "anybodi know"    "hart polici"     "reign god"      
## [5] "fall familiar"   "declar failur"
```

```r
head(names(sort(-B_prop)[1:10])) # High repshare (Repubs)
```

```
## [1] "100 billssh"   "typic white"   "1 2006practic" "job immigr"   
## [5] "larri korb"    "racist origin"
```

```r
# plot AICc curves
# ll <- log(lassoslant$lambda) # the sequence of lambdas
# ll <- log(lassoslant$lambda.1se) # the sequence of lambdas
# # plot(ll, AICc(lassoslant)/length(y), xlab = "log lambda", ylab = "AICc/n", pch = 21, bg = "orange")
# plot(ll, AICc(lassoslant$lambda.1se)/length(y), xlab = "log lambda", ylab = "AICc/n", pch = 21, bg = "orange")
# abline(v = ll[which.min(AICc(lassoslant))], col = "orange", lty = 3)
# abline(v = ll[which.min(AICc(lassoslant_prop))], col = "black", lty = 3)
# points(ll, AICc(lassoslant_prop)/length(y), pch = 21, bg = "black")
# legend("topright", bty = "n", fill = c("black", "orange"), legend = c("lassoslant", "lassoslant_prop"))



# Prediction

coefficients_lasso <- pivot_longer(coefficients_lasso2, cols = everything(), names_to = "phrase",  values_to = "coefficient")
coefficients_lasso$phrase <- gsub('X', '', coefficients_lasso$phrase)
coefficients_lasso$phrase <- gsub('X', '', coefficients_lasso$phrase)
coefficients_lasso$phrase <- gsub('[[:punct:] ]+',' ',coefficients_lasso$phrase)
coefficients_lasso$phrase <- trimws(coefficients_lasso$phrase, which = c("both"))

# number of coefficients
length(coefficients_lasso2)
```

```
## [1] 302
```

```r
# reactable(coefficients_lasso)
#rm(df,toks_dfm,toks_ngram,DF,x,X,x_prop)
```

# Coefficient Table

Remember that R=1 and D=0


```r
htmltools::tagList(
  reactable::reactable(coefficients_lasso)
)
```

```{=html}
<div id="htmlwidget-878bf09bd90d2c783806" class="reactable html-widget" style="width:auto;height:auto;"></div>
<script type="application/json" data-for="htmlwidget-878bf09bd90d2c783806">{"x":{"tag":{"name":"Reactable","attribs":{"data":{"phrase":["american progressse","american progress","american progressmor","american progressfor","rang institut","still sore","peopl employerprovid","independ global","damag disast","baptist associ","web erin","unscrupul lender","pollut industri","column base","latino children","dma lindsey","done medicar","practic dont","stakehold interview","lecompt media","economist center","barrier obtain","build evid","util project","list sourc","conathan director","gaza cross","also valid","contain separ","one stationari","cuba must","insur drop","valdez spill","communiti societi","inform seevideo","confus work","read center","sustain secur","davenport director","women doctor","potenti sexual","qualiti coordin","director middl","progress 2050","citi resourc","team center","progressth author","memo pdf","previous busi","legal progress","togeth solv","read full","avail assess","final border","fact keep","american progressauthor","korea fuel","progress polici","assist progress","american there","fellow center","leverag temporari","hous product","report pdf","orient discrimin","climat changeand","motiv creat","often teen","lesbian across","week continu","fulwood iii","american progressthank","analyst american","initiativeat center","interfaith organ","disproportion affect","margetta morgan","enabl poorer","depart center","cia prison","energi demand","discrimin samesex","clean altern","hart polici","ask paper","domest climat","women initi","hybrid vehicl","center american","evangel environment","irrit respiratori","lowwag job","ryan rwi","rate attend","valu public","senior peopl","slip bankruptci","access job","duss polici","peak 112","fair pay","secur peacebuild","almost occup","team individu","poll 59","congreg particular","smallscal farmer","generat gap","pregnanc host","exacerb competit","accur analyz","alterman senior","initi center","mortgag crisi","percent endors","dont ask","antiimmigr law","women access","hispan unemploy","disast public","polici center","nonhispan black","exacerb climat","choos job","major emitt","safe drink","number women","age order","form mortgageback","week wage","pleas seeth","undocu immigr","presid barack","progressauthor note","state latino","bisexu transgend","carolin wadham","poll public","east progress","millenni access","lieberman ict","media strategi","peopl color","tortur enhanc","program center","vulner develop","project center","unlead gasolin","march 2001","job growth","effect warm","racial ethnic","told chicago","church year","gay lesbian","kenworthi senior","oil compani","gay men","human health","train 600","book evangel","lowwag worker","program servic","supervis staff","renew energi","cycl start","lilli senior","health wellb","longterm unemploy","white worker","gulf mexico","african american","everyon come","requir partner","latino asian","like experi","youth adult","scienc progress","task assess","epa studi","reproduct health","per barrel","us workforc","associ director","regionth unit","intern communiti","religi leader","climat chang","director media","across countri","deni women","subject work","access health","wto intern","organ interfaith","sinc women","10 calcul","10 creatingunemploymenthtml","10 expert","100 weekit","10point scale","10point scalea","11 household","12 calcul","12 payrolltaxhtml","12point increas","13 consecut","131000dure period","138000 per","150000 activeduti","1749 victim","1790 possess","18 monthsth","19 08","1930s evid","1930slike depress","1960s critic","1974 1984","1975 hold","1990s sen","1993 deleon","19941997 nomin","1995 fulbright","2 homeown","2 percentwil","2001 support","20072009 subsequ","2017the fbi","780000 job","784000 averag","832 percentfrom","academicsalthough expert","acceler payrol","accord beliefsunfortun","accord ideolog","act spendingjob","afterward tax","ago 12point","ago 91","allah awaken","almost consensus","analyst numer","anticip second","antijewish bias","antimuslim antihindu","anytim soonboth","anywherea democrat","appear varieti","appearancesat begin","apprais repres","arsenal 311","arthur ron","ask selfidentifi","ask turn","averag 131000dure","averag 192000","borchgrav jame","briefli recount","brighten passag","britt snider","burden faster","byman john","came crucial","carpent joseph","case thought","ceilingth maximum","major cathol","plant number","antihindu antiprotest","cbo reduc","associ negoti","cbc voic","amount overlap","expert say","asia publish","expans end","govern polit","boost incom","cato institut","heritag foundat","origin appear","kenneth katzman","articl appear","anticathol also","creat equit","idea driven","antidefam leagu","686 billion","amid slow","07 defaultdangershtml","american boost","thousand net","posit number","diploma drop","11 levelsprocur","100 billssh","overal percentag","driven solut","pollut futur","americanprogressorgcarolin wadham","address infrastructur","08 sign"],"coefficient":[-0.5083,-0.433,-0.4321,-0.4319,-0.3911,-0.3235,-0.3227,-0.2358,-0.2193,-0.2024,-0.1842,-0.1838,-0.1801,-0.1536,-0.1515,-0.1418,-0.1349,-0.1349,-0.1349,-0.1346,-0.1307,-0.1301,-0.1295,-0.1253,-0.1236,-0.1235,-0.1227,-0.1211,-0.1211,-0.1193,-0.1153,-0.115,-0.114,-0.1134,-0.1128,-0.1057,-0.1006,-0.0959,-0.0935,-0.091,-0.0898,-0.0898,-0.0875,-0.087,-0.0869,-0.0867,-0.0853,-0.0851,-0.0825,-0.0813,-0.0807,-0.0794,-0.0784,-0.0753,-0.0748,-0.073,-0.0705,-0.0705,-0.0697,-0.0684,-0.0679,-0.0654,-0.0647,-0.0645,-0.0641,-0.064,-0.0634,-0.0617,-0.061,-0.0599,-0.0597,-0.0592,-0.0586,-0.058,-0.0556,-0.0548,-0.0543,-0.0539,-0.0533,-0.0531,-0.0527,-0.0526,-0.0525,-0.0511,-0.0509,-0.0505,-0.0502,-0.0496,-0.0482,-0.0482,-0.0482,-0.0479,-0.0476,-0.0474,-0.0464,-0.0452,-0.0449,-0.0446,-0.0441,-0.0438,-0.043,-0.0428,-0.0426,-0.042,-0.0393,-0.0384,-0.0382,-0.0373,-0.0372,-0.0363,-0.0359,-0.0355,-0.0346,-0.0336,-0.0336,-0.0329,-0.0326,-0.0323,-0.0315,-0.0308,-0.0306,-0.0304,-0.0292,-0.029,-0.0278,-0.0276,-0.0261,-0.0254,-0.0254,-0.0254,-0.0252,-0.0251,-0.0234,-0.0231,-0.0199,-0.0186,-0.0186,-0.0183,-0.0179,-0.0178,-0.0177,-0.0174,-0.0169,-0.0169,-0.0165,-0.0164,-0.0158,-0.0153,-0.015,-0.0148,-0.0145,-0.0129,-0.0128,-0.0121,-0.012,-0.0118,-0.0115,-0.0111,-0.0108,-0.0106,-0.0103,-0.0102,-0.0099,-0.0099,-0.0096,-0.0095,-0.0092,-0.0091,-0.009,-0.0084,-0.008,-0.0063,-0.0056,-0.0054,-0.0052,-0.0045,-0.0043,-0.0041,-0.0041,-0.0039,-0.0037,-0.0032,-0.0027,-0.0022,-0.0022,-0.0021,-0.0021,-0.0019,-0.0019,-0.0014,-0.0014,-0.0013,-0.0006,-0.0005,-0.0004,-0.0001,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0,-0,0.0001,0.0003,0.0004,0.0019,0.0024,0.0028,0.0039,0.0043,0.0045,0.006,0.0073,0.0101,0.0123,0.0163,0.02,0.0454,0.0553,0.0559,0.0584,0.0797,0.0837,0.0924,0.1151,0.1287,0.1727,0.1745,0.1782,0.2028,0.2499,0.2988,0.3525,0.3538,0.4428,1.1536]},"columns":[{"accessor":"phrase","name":"phrase","type":"character"},{"accessor":"coefficient","name":"coefficient","type":"numeric"}],"defaultPageSize":10,"paginationType":"numbers","showPageInfo":true,"minRows":1,"dataKey":"728372766163dac7e1031394ce1f18b8"},"children":[]},"class":"reactR_markup"},"evals":[],"jsHooks":[]}</script>
```

```r
knitr::knit_exit()
```
















