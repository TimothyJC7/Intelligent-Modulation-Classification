function [trainData,validData,testData] = SplitData(DataCA,splitPercentages,framesPerMod)

trainper = splitPercentages(1)*0.01;
validper = splitPercentages(2)*0.01;
testper = splitPercentages(3)*0.01;

dataSet = DataCA;

numOfMods = 8;

trainData = {numOfMods,framesPerMod*trainper};
validData = {numOfMods,framesPerMod*validper};
testData = {numOfMods,framesPerMod*testper};

    for modType = 1:numOfMods
        rNum = randperm(framesPerMod);
        for frame = 1:framesPerMod
            if frame <= framesPerMod*trainper
                trainData{modType,frame} = dataSet{modType,rNum(frame)}; 
            elseif frame >= (framesPerMod*trainper + 1) && frame <= (framesPerMod * (trainper + validper))
                validData{modType,(frame - framesPerMod*trainper)} = dataSet{modType,rNum(frame)};
            else
                testData{modType,(frame - (framesPerMod * (trainper + validper)))} = dataSet{modType,rNum(frame)};
            end
        end
    end
end

