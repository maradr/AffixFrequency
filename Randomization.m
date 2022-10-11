    %% Randomizing Stimuli
    n_examples = 2;
    n_practice = 8;
    n_warmup = 4;
    n_trialsperblock = 16;
    n_experimental_items = 80;
    
    Table.target = upper(Table.target);
    ExperimentalList = table2struct(Table); % Convert into structure
    %Create a temporary copy; otherwise, it will read itself while overwriting, causing repetitions
    ExperimentalList_temp = ExperimentalList;
    BlockIntervals = n_examples+n_practice+n_warmup+1:n_trialsperblock:length(ExperimentalList);
    RandomizedBlock = BlockIntervals(randperm(length(BlockIntervals)));
    
    ExperimentalList(1:n_examples) = ExperimentalList_temp(randperm(length(ExperimentalList_temp(1:n_examples))));
    Training = ExperimentalList_temp(n_examples+1:n_examples+n_practice);
    ExperimentalList(n_examples+1:n_examples+n_practice) =  Training(randperm(length(Training)));
    WarmUp = ExperimentalList_temp(n_examples+n_practice+1:n_examples+n_practice+n_warmup);
    ExperimentalList(n_examples+n_practice+1:n_examples+n_practice+n_warmup) = WarmUp(randperm(length(WarmUp)));
    
    % Randomizing both blocks and items
    for i=1:length(BlockIntervals)
        Block = ExperimentalList_temp(BlockIntervals(i):BlockIntervals(i)+n_trialsperblock-1);
        ExperimentalList(RandomizedBlock(i):RandomizedBlock(i)+n_trialsperblock-1) = Block(randperm(length(Block)));
    end