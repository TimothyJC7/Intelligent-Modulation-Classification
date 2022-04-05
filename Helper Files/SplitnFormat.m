function [trainDatanLabels,validDatanLabels,testDatanLabels] = SplitnFormat(dataCA,modulationTypes,splitPercentages,dataInfo)

numOfModTypes = dataInfo(1);
framesPerModType = dataInfo(2);
trainper = splitPercentages(1)*0.01;
validper = splitPercentages(2)*0.01;
testper = splitPercentages(3)*0.01;

trainDatanLabels = cell(framesPerModType*trainper*numOfModTypes,2);
validDatanLabels = cell(framesPerModType*validper*numOfModTypes,2);
testDatanLabels = cell(framesPerModType*testper*numOfModTypes,2);

reshapedData = reshape(dataCA.',[1 framesPerModType*numOfModTypes])';
labels = repelem(modulationTypes,framesPerModType)';
rp = randperm(framesPerModType*numOfModTypes);
comb_Data_Labels = cat(2,reshapedData,num2cell(labels));
rand_Data_Labels = cat(2,comb_Data_Labels(rp,1),comb_Data_Labels(rp,2));

for modtype = 1:numOfModTypes
    for frame = 1:framesPerModType
            if frame <= framesPerModType*trainper
                trainDatanLabels{frame + (modtype - 1)*framesPerModType*trainper,1} = rand_Data_Labels{frame + (modtype - 1)*framesPerModType,1};
                trainDatanLabels{frame + (modtype - 1)*framesPerModType*trainper,2} = rand_Data_Labels{frame + (modtype - 1)*framesPerModType,2};
            elseif (frame >= (framesPerModType*trainper + 1)) && frame <= ((framesPerModType*(trainper + validper)))
                validDatanLabels{(frame - framesPerModType*trainper) + (modtype - 1)*framesPerModType*validper,1} = rand_Data_Labels{frame + (modtype - 1)*framesPerModType,1};
                validDatanLabels{(frame - framesPerModType*trainper) + (modtype - 1)*framesPerModType*validper,2} = rand_Data_Labels{frame + (modtype - 1)*framesPerModType,2};
            else
                testDatanLabels{(frame - (framesPerModType*(trainper + validper))) + (modtype - 1)*framesPerModType*testper,1} = rand_Data_Labels{frame + (modtype - 1)*framesPerModType,1};
                testDatanLabels{(frame - (framesPerModType*(trainper + validper))) + (modtype - 1)*framesPerModType*testper,2} = rand_Data_Labels{frame + (modtype - 1)*framesPerModType,2};
            end 
    end
end

end

