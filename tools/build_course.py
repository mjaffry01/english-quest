"""200 activities x 100 graded patterns = 20,000 unique practice pairs.
These are structured variations, not 20,000 unrelated stories.
"""
import json
from pathlib import Path

THEMES = [
('Home base','घर और परिवार','🏡', '''कमरा साफ़ करना|clean the room
बिस्तर ठीक करना|make the bed
दरवाज़ा खोलना|open the door
खिड़की बंद करना|close the window
पौधों को पानी देना|water the plants
मेज़ सजाना|set the table
कपड़े मोड़ना|fold the clothes
बैग तैयार करना|pack the bag
जूते साफ़ करना|clean the shoes
दादी की मदद करना|help Grandma
दादाजी को फ़ोन करना|call Grandpa
दीपक जलाना|light the lamp
तस्वीर लगाना|put up the picture
खिलौने समेटना|put away the toys
चाबी ढूँढ़ना|find the key
बत्ती बुझाना|turn off the light
तकिया ठीक करना|adjust the pillow
किताबें सजाना|arrange the books
कुर्सी लाना|bring the chair
परिवार के साथ समय बिताना|spend time with the family'''),
('School squad','स्कूल और दोस्त','🎒', '''किताब पढ़ना|read the book
कहानी लिखना|write a story
सवाल पूछना|ask a question
उत्तर जाँचना|check the answer
नए शब्द का प्रयोग करना|use a new word
कविता सुनाना|recite a poem
नक्शा बनाना|draw a map
पेंसिल ढूँढ़ना|find the pencil
दोस्त की मदद करना|help a friend
शिक्षक की बात सुनना|listen to the teacher
गणित का सवाल हल करना|solve a maths problem
बोर्ड साफ़ करना|clean the board
नोट्स बनाना|take notes
पाठ दोहराना|revise the lesson
वाक्य पूरा करना|complete the sentence
पुस्तकालय जाना|go to the library
प्रोजेक्ट पूरा करना|finish the project
कक्षा सजाना|decorate the classroom
अपना परिचय देना|introduce ourselves
शब्दों की वर्तनी जाँचना|check the spelling of the words'''),
('Play makers','खेल और मस्ती','⚽', '''क्रिकेट खेलना|play cricket
पतंग उड़ाना|fly a kite
गेंद पकड़ना|catch the ball
रस्सी कूदना|skip rope
साइकिल चलाना|ride a bicycle
शतरंज खेलना|play chess
पहेली हल करना|solve a puzzle
कागज़ की नाव बनाना|make a paper boat
रेत का किला बनाना|build a sandcastle
गोल करना|score a goal
टीम बनाना|form a team
खेल के नियम पढ़ना|read the rules of the game
खिलाड़ी का हौसला बढ़ाना|encourage the player
टेनिस खेलना|play tennis
पानी में तैरना|swim in water
दौड़ में भाग लेना|take part in a race
गुब्बारा फुलाना|blow up a balloon
खेल की योजना बनाना|plan a game
खेल का सामान समेटना|put away the sports equipment
जीत का जश्न मनाना|celebrate the victory'''),
('Kitchen club','रसोई का जादू','🍎', '''हाथ धोना|wash our hands
सेब धोना|wash the apple
सलाद बनाना|make a salad
दूध गरम करना|heat the milk
सूप चखना|taste the soup
रोटी बनाना|make roti
पानी पीना|drink water
फल बाँटना|share the fruit
दाल पकाना|cook lentils
चावल धोना|wash the rice
थाली लाना|bring the plate
चम्मच गिनना|count the spoons
नाश्ता तैयार करना|prepare breakfast
खाने का डिब्बा भरना|fill the lunch box
आम चुनना|choose a mango
दही जमाना|make yoghurt
बर्तन धोना|wash the dishes
मेज़ पोंछना|wipe the table
खाने की विधि पढ़ना|read the recipe
सब्ज़ियाँ खरीदना|buy vegetables'''),
('Wild wonders','प्रकृति के दोस्त','🦋', '''पेड़ लगाना|plant a tree
पक्षियों को देखना|watch the birds
पत्ते गिनना|count the leaves
फूल की तस्वीर बनाना|draw a flower
कुत्ते को खाना देना|feed the dog
बिल्ली के लिए पानी रखना|put out water for the cat
तितली की तस्वीर लेना|take a photo of a butterfly
बगीचे में चलना|walk in the garden
बीज बोना|sow seeds
तालाब देखना|look at the pond
पक्षियों की आवाज़ सुनना|listen to the birds
सूखे पत्ते इकट्ठा करना|collect dry leaves
पौधे की ऊँचाई मापना|measure the height of the plant
खरगोश की देखभाल करना|look after the rabbit
बगीचे से कचरा उठाना|pick up litter in the garden
बादलों को देखना|watch the clouds
पेड़ों की पहचान करना|identify trees
बारिश का पानी इकट्ठा करना|collect rainwater
घोंसले को दूर से देखना|watch the nest from a distance
जानवरों के बारे में पढ़ना|read about animals'''),
('City explorers','शहर की सैर','🚌', '''बस का इंतज़ार करना|wait for the bus
टिकट खरीदना|buy a ticket
रास्ता पूछना|ask for directions
संग्रहालय जाना|visit the museum
पुल देखना|look at the bridge
सड़क पार करना|cross the road
यातायात के नियम समझना|understand the traffic rules
स्टेशन ढूँढ़ना|find the station
दुकानदार से बात करना|talk to the shopkeeper
पैसे गिनना|count the money
डाकघर जाना|go to the post office
पत्र भेजना|send a letter
पार्क का नक्शा पढ़ना|read the map of the park
बाज़ार घूमना|explore the market
सीट ढूँढ़ना|find a seat
पानी की बोतल भरना|fill the water bottle
समय देखना|check the time
सही बस चुनना|choose the right bus
कूड़ेदान ढूँढ़ना|find a rubbish bin
घर का रास्ता याद रखना|remember the way home'''),
('Space lab','विज्ञान और अंतरिक्ष','🚀', '''चाँद देखना|look at the Moon
तारे गिनना|count the stars
रॉकेट का मॉडल बनाना|make a model rocket
ग्रहों की पहचान करना|identify the planets
दूरबीन के बारे में पढ़ना|read about telescopes
छाया मापना|measure a shadow
तापमान लिखना|record the temperature
चुंबक से प्रयोग करना|experiment with a magnet
कागज़ का हवाई जहाज़ बनाना|make a paper aeroplane
सौरमंडल का चित्र बनाना|draw the solar system
विज्ञान की कहानी पढ़ना|read a science story
रोबोट का चित्र बनाना|draw a robot
पानी की मात्रा मापना|measure the amount of water
प्रयोग के नतीजे लिखना|write down the results of the experiment
सुरक्षा के नियम पढ़ना|read the safety rules
पत्थरों की तुलना करना|compare rocks
इंद्रधनुष के रंग पहचानना|identify the colours of the rainbow
अंतरिक्ष यात्री के बारे में पढ़ना|read about an astronaut
प्रयोग की योजना बनाना|plan an experiment
वैज्ञानिक से सवाल पूछना|ask a scientist a question'''),
('Creative studio','कला और कल्पना','🎨', '''चित्र बनाना|draw a picture
गीत गाना|sing a song
ढोल बजाना|play the drum
नाटक लिखना|write a play
मुखौटा बनाना|make a mask
रंग मिलाना|mix colours
पोस्टर बनाना|make a poster
नृत्य करना|dance
कहानी सुनाना|tell a story
कविता लिखना|write a poem
मिट्टी का खिलौना बनाना|make a clay toy
कागज़ मोड़ना|fold paper
जन्मदिन का कार्ड बनाना|make a birthday card
मंच सजाना|decorate the stage
संवाद याद करना|memorise the dialogue
संगीत सुनना|listen to music
कठपुतली बनाना|make a puppet
कहानी का अंत बदलना|change the ending of the story
पात्र का नाम चुनना|choose a name for the character
कला प्रदर्शनी लगाना|hold an art exhibition'''),
('Kindness crew','मिलकर बेहतर बनें','🤝', '''दोस्त का स्वागत करना|welcome a friend
धन्यवाद कहना|say thank you
माफ़ी माँगना|apologise
किसी की बात ध्यान से सुनना|listen carefully to someone
छोटे बच्चे की मदद करना|help a young child
अपनी बारी का इंतज़ार करना|wait for our turn
खिलौने बाँटना|share toys
दोस्त को हँसाना|make a friend laugh
किसी की तारीफ़ करना|compliment someone
सच बोलना|tell the truth
वादा निभाना|keep a promise
झगड़ा सुलझाना|settle an argument
नए बच्चे से दोस्ती करना|befriend the new child
ज़रूरतमंदों के लिए किताबें इकट्ठा करना|collect books for people in need
पड़ोसी की मदद करना|help a neighbour
किसी का जन्मदिन याद रखना|remember someone's birthday
टीम की बात सुनना|listen to the team
अच्छा सुझाव देना|make a helpful suggestion
मिलकर काम करना|work together
मेहनत की सराहना करना|appreciate hard work'''),
('Adventure guild','नई चुनौतियाँ','🧭', '''यात्रा की योजना बनाना|plan a trip
बैग का वज़न जाँचना|check the weight of the bag
तंबू लगाना|pitch a tent
दिशा पहचानना|identify the direction
पहाड़ का चित्र बनाना|draw a mountain
झरने की तस्वीर लेना|take a photo of a waterfall
डायरी लिखना|write a diary
यात्रा का खर्च गिनना|calculate the cost of the trip
मौसम की जानकारी लेना|check the weather forecast
नए कौशल का अभ्यास करना|practise a new skill
अपना लक्ष्य लिखना|write down our goal
समस्या का हल ढूँढ़ना|find a solution to the problem
ज़रूरी सामान की सूची बनाना|make a list of essential items
यात्रा की कहानी सुनाना|tell the story of the trip
समय पर लौटना|return on time
दोस्तों को योजना समझाना|explain the plan to our friends
सुरक्षित रास्ता चुनना|choose a safe route
अपनी प्रगति जाँचना|check our progress
अगली चुनौती चुनना|choose the next challenge
अपनी सफलता का जश्न मनाना|celebrate our success''')]

# Infinitive composition is deliberate; no guessed past participles or genders.
LEVELS = [
('First steps','Use want, need and should with the base verb.', '''हम {h} चाहते हैं।|We want to {e}.
हम {h} सीख रहे हैं।|We are learning to {e}.
हमें {h} है।|We need to {e}.
क्या हम {h} सीख सकते हैं?|Can we learn to {e}?
हमें {h} पसंद है।|We like to {e}.
हम {o} के लिए तैयार हैं।|We are ready to {e}.
आओ, {h} सीखें।|Let us learn to {e}.
क्या तुम {h} चाहते हो?|Do you want to {e}?
हमें {h} चाहिए।|We should {e}.
हमें {h} नहीं भूलना चाहिए।|We should not forget to {e}.'''),
('Everyday choices','Notice negatives and time words.', '''आज हम {h} चाहते हैं।|We want to {e} today.
कल हमें {h} है।|We need to {e} tomorrow.
अभी हमें {h} नहीं है।|We do not need to {e} right now.
क्या आज हमें {h} चाहिए?|Should we {e} today?
स्कूल के बाद हम {h} चाहते हैं।|We want to {e} after school.
पहले हमें {h} है।|First, we need to {e}.
बाद में हम {h} सीखेंगे।|We will learn to {e} later.
हर रविवार हम {h} चाहते हैं।|We want to {e} every Sunday.
आज हमें {h} नहीं भूलना चाहिए।|We should not forget to {e} today.
इस सप्ताह हमें {h} है।|We need to {e} this week.'''),
('Curious questions','Practise what, why, when, where and how.', '''हमें {h} कब सीखना चाहिए?|When should we learn to {e}?
तुम {h} क्यों चाहते हो?|Why do you want to {e}?
हम {h} कहाँ सीख सकते हैं?|Where can we learn to {e}?
क्या तुम हमें {h} सिखा सकते हो?|Can you teach us to {e}?
{o} के लिए हमें क्या चाहिए?|What do we need in order to {e}?
हमें {h} कौन सिखाएगा?|Who will teach us to {e}?
क्या तुम्हें {h} पसंद है?|Do you like to {e}?
हमें {h} क्यों सीखना चाहिए?|Why should we learn to {e}?
तुम {h} कब सीखना चाहते हो?|When do you want to learn to {e}?
हम {h} कैसे सीख सकते हैं?|How can we learn to {e}?'''),
('Yesterday and tomorrow','Move through time with wanted, needed and will.', '''कल हम {h} चाहते थे।|We wanted to {e} yesterday.
पिछले सप्ताह हमें {h} था।|We needed to {e} last week.
हमने {h} सीख लिया है।|We have learned to {e}.
हम अभी तक {h} नहीं सीख पाए हैं।|We have not yet learned to {e}.
अगले महीने हम {h} सीखेंगे।|We will learn to {e} next month.
हमने {o} का फैसला किया।|We decided to {e}.
हमने {o} की कोशिश की।|We tried to {e}.
हम {h} सीख रहे थे।|We were learning to {e}.
हमें याद था कि हमें {h} है।|We remembered that we needed to {e}.
हम भूल गए कि हमें {h} था।|We forgot that we needed to {e}.'''),
('Reasons and feelings','Join ideas with because, but and so.', '''हम {h} चाहते हैं क्योंकि यह मज़ेदार है।|We want to {e} because it is fun.
हमें {h} है, लेकिन हमारे पास समय कम है।|We need to {e}, but we have little time.
हम {h} सीख रहे हैं, इसलिए हम उत्साहित हैं।|We are learning to {e}, so we are excited.
हम {h} चाहते थे, लेकिन बारिश शुरू हो गई।|We wanted to {e}, but it started raining.
हमें {h} पसंद है क्योंकि इससे हमें खुशी मिलती है।|We like to {e} because it makes us happy.
हम {h} सीखना चाहते हैं, इसलिए हम मदद माँग रहे हैं।|We want to learn to {e}, so we are asking for help.
हमने {o} का फैसला किया क्योंकि हमारे पास समय था।|We decided to {e} because we had time.
हमें {h} था, लेकिन हम भूल गए।|We needed to {e}, but we forgot.
हम {o} के लिए तैयार हैं, लेकिन हमारे दोस्त अभी तैयार नहीं हैं।|We are ready to {e}, but our friends are not ready yet.
हमें {h} सीखना चाहिए क्योंकि अभ्यास ज़रूरी है।|We should learn to {e} because practice is important.'''),
('Polite problem solvers','Make polite requests, suggestions and offers.', '''क्या आप कृपया हमें {h} सिखा सकते हैं?|Could you please teach us to {e}?
हम {h} सीखना चाहेंगे।|We would like to learn to {e}.
क्या हमारे लिए अभी {h} ठीक रहेगा?|Would it be all right for us to {e} now?
क्या आप हमें {o} की अनुमति देंगे?|Would you allow us to {e}?
आपकी मदद से हम {h} सीख सकते हैं।|With your help, we can learn to {e}.
मेरा सुझाव है कि हम {h} सीखें।|I suggest that we learn to {e}.
कृपया हमें बताइए कि {o} के लिए क्या चाहिए।|Please tell us what we need in order to {e}.
क्या आप हमें दिखाएँगे कि {h} सीखना कैसे शुरू करें?|Would you show us how to start learning to {e}?
अगर आपको समय मिले, तो कृपया हमें {h} सिखाइए।|If you have time, please teach us to {e}.
हमें {h} सिखाने के लिए धन्यवाद।|Thank you for teaching us to {e}.'''),
('What if?','Explore real and imaginary conditions.', '''अगर समय मिला, तो हम {h} सीखेंगे।|If we have time, we will learn to {e}.
अगर हमारे पास ज़्यादा समय होता, तो हम {h} सीखते।|If we had more time, we would learn to {e}.
अगर तुम तैयार हो, तो हम {h} शुरू कर सकते हैं।|If you are ready, we can start to {e}.
अगर हमें मदद मिलती, तो हम {h} सीख सकते थे।|If we had help, we could learn to {e}.
जब तक हम अभ्यास नहीं करेंगे, हम {h} नहीं सीख पाएँगे।|Unless we practise, we will not be able to learn to {e}.
अगर हमें मौका मिला, तो हम {h} चाहेंगे।|If we get a chance, we would like to {e}.
भले ही समय कम हो, हम {h} सीखना चाहते हैं।|Even if time is short, we want to learn to {e}.
अगर तुम्हें {h} पसंद है, तो हमारे साथ आओ।|If you like to {e}, come with us.
अगर हम ध्यान दें, तो हम {h} जल्दी सीख सकते हैं।|If we pay attention, we can learn to {e} quickly.
अगर हमें {h} है, तो पहले योजना बनानी चाहिए।|If we need to {e}, we should make a plan first.'''),
('Story builders','Connect events with before, after, while and although.', '''{h} सीखने के बाद, हमने दूसरों की मदद की।|After learning to {e}, we helped others.
{h} शुरू करने से पहले, हमने निर्देश पढ़े।|Before starting to {e}, we read the instructions.
जब हम {h} सीख रहे थे, तब हमारे दोस्त आए।|While we were learning to {e}, our friends arrived.
हालाँकि हम थके हुए थे, फिर भी हम {h} चाहते थे।|Although we were tired, we still wanted to {e}.
जैसे ही हमें समय मिला, हमने {h} सीखना शुरू किया।|As soon as we had time, we started learning to {e}.
हम तब तक कोशिश करते रहे जब तक हमने {h} नहीं सीख लिया।|We kept trying until we learned to {e}.
जब तक शिक्षक आए, हम {o} के लिए तैयार हो चुके थे।|By the time the teacher arrived, we were ready to {e}.
{h} सीखते समय, हमने कई गलतियाँ कीं।|While learning to {e}, we made several mistakes.
हालाँकि शुरुआत मुश्किल थी, हमने {h} सीख लिया।|Although the beginning was difficult, we learned to {e}.
{o} के बजाय, हमने पहले योजना बनाने का फैसला किया।|Instead of proceeding to {e}, we decided to make a plan first.'''),
('Explain your thinking','Report ideas and give thoughtful explanations.', '''शिक्षक ने कहा कि हमें {h} सीखना चाहिए।|The teacher said that we should learn to {e}.
हमने समझाया कि हम {h} क्यों चाहते थे।|We explained why we wanted to {e}.
हमारे दोस्तों ने पूछा कि क्या हम {h} सीख रहे थे।|Our friends asked whether we were learning to {e}.
हमारा मानना है कि हर किसी को {h} सीखने का मौका मिलना चाहिए।|We believe that everyone should have a chance to learn to {e}.
हमें एहसास हुआ कि {h} सीखने में समय लगता है।|We realised that learning to {e} takes time.
शिक्षक ने हमें याद दिलाया कि हमें {h} था।|The teacher reminded us that we needed to {e}.
हम इस बात पर सहमत हुए कि {o} से पहले योजना बनाना ज़रूरी है।|We agreed that it is important to plan before we {e}.
हमने सोचा कि {h} सीखने का सबसे अच्छा तरीका क्या होगा।|We wondered what the best way to learn to {e} would be.
हमने वादा किया कि हम अपने दोस्तों को {h} सिखाएँगे।|We promised that we would teach our friends to {e}.
हमने बताया कि {h} सीखने से हमारा आत्मविश्वास बढ़ा।|We said that learning to {e} had increased our confidence.'''),
('Confident communicator','Combine conditions, reflection and complex clauses.', '''अगर हमने पहले अभ्यास किया होता, तो हम अब तक {h} सीख चुके होते।|If we had practised earlier, we would have learned to {e} by now.
हालाँकि हमें यकीन नहीं था कि हम सफल होंगे, हमने {h} सीखने की कोशिश की।|Although we were not sure that we would succeed, we tried to learn to {e}.
हमने न केवल {h} सीखा, बल्कि दूसरों को भी सिखाया।|We not only learned to {e}, but also taught others.
अब जब हमने {h} सीख लिया है, हम एक नई चुनौती के लिए तैयार हैं।|Now that we have learned to {e}, we are ready for a new challenge.
चाहे कितना भी समय लगे, हम {h} सीखने की कोशिश जारी रखेंगे।|No matter how long it takes, we will keep trying to learn to {e}.
{h} सीखने का हमारा फैसला इस विश्वास पर आधारित था कि अभ्यास से सुधार होता है।|Our decision to learn to {e} was based on the belief that practice leads to improvement.
पीछे मुड़कर देखने पर, हमें लगता है कि हमें {h} पहले सीखना चाहिए था।|Looking back, we feel that we should have learned to {e} earlier.
जिस बात ने हमें सबसे ज़्यादा हैरान किया, वह यह थी कि हमने कितनी जल्दी {h} सीख लिया।|What surprised us most was how quickly we learned to {e}.
यदि हमें दोबारा मौका मिलता, तो भी हम {h} सीखना चुनते।|If we had the chance again, we would still choose to learn to {e}.
{h} सीखने से हमें यह समझ आया कि धैर्य उतना ही ज़रूरी है जितना उत्साह।|Learning to {e} helped us understand that patience is just as important as enthusiasm.''')]

def build():
    days=[]
    for level,(name,tip,raw_patterns) in enumerate(LEVELS):
        patterns=[line.split('|') for line in raw_patterns.splitlines()]
        assert len(patterns)==10
        for theme,(title,hindi,emoji,raw_actions) in enumerate(THEMES):
            actions=[line.split('|') for line in raw_actions.splitlines()]
            assert len(actions)==20
            pairs=[]
            for p,(ht,et) in enumerate(patterns):
                for a,(h,e) in enumerate(actions):
                    assert h.endswith('ना'), h
                    # Match possessives/reflexives to the template's subject.
                    if et.startswith(('Do you', 'Why do you', 'When do you', 'If you like')):
                        e=e.replace('ourselves','yourselves').replace('our ', 'your ')
                    elif 'everyone should' in et:
                        e=e.replace('ourselves','themselves').replace('our ', 'their ')
                    vals=dict(h=h,o=h[:-2]+'ने',e=e)
                    pairs.append(dict(id=f'{len(days)+1}-{p*20+a+1}',hi=ht.format(**vals),en=et.format(**vals),round=p+1))
            days.append(dict(day=len(days)+1,level=level+1,levelName=name,title=title,hindi=hindi,emoji=emoji,tip=tip,pairs=pairs))
    assert len(days)==100 and all(len(d['pairs'])==200 for d in days)
    pairs=[p for d in days for p in d['pairs']]
    assert len({p['hi'] for p in pairs})==20000
    assert len({p['en'] for p in pairs})==20000
    out=Path(__file__).resolve().parents[1]/'assets'/'course.json'
    out.parent.mkdir(exist_ok=True)
    out.write_text(json.dumps(days,ensure_ascii=False,separators=(',',':')),encoding='utf-8')
    print(f'Validated {len(days)} days, {len(pairs)} unique bilingual pairs; {out.stat().st_size:,} bytes.')
if __name__=='__main__': build()
