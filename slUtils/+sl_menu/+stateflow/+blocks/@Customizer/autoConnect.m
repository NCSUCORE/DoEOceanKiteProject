% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = autoConnect(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines createBusObject menu item

schema          = sl_action_schema();               % Initialize schema
schema.tag      = 'SimulinkUtils:SF:AutoConnect';   % Set menu item tag
schema.label    = 'Auto connect';                   % Set menu item label
schema.callback = @autoConnectCb;                   % Set callback function

end

function autoConnectCb(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium

selectedBlocks = sfgco;

if length(selectedBlocks) ~= 2
    % Nothing to do.
    return
end

% Create a transition between the two blocks.
fromBlock               = selectedBlocks(1);
toBlock                 = selectedBlocks(2);

transition              = Stateflow.Transition(toBlock.Chart);
transition.Source      	= fromBlock;
transition.Destination 	= toBlock;

% Check the positioning of the blocks to determine transition tangents.
pos{1}                  = transition.Source.Position;
pos{2}                  = transition.Destination.Position;

clearPos(2)             = struct('t', [], 'r', [], 'b', [], 'l', []);

for iPos = 1:2
    
    if isnumeric(pos{iPos})
        % Get the corner positions.
        clearPos(iPos).t    = pos{iPos}(2);
        clearPos(iPos).r    = pos{iPos}(1) + pos{iPos}(3);
        clearPos(iPos).b    = pos{iPos}(2) + pos{iPos}(4);
        clearPos(iPos).l    = pos{iPos}(1);
    elseif isa(pos{iPos}, 'Stateflow.JunctionPosition')
        % Derive the 'corners' from center and radius.
        clearPos(iPos).t    = pos{iPos}.Center(2) - pos{iPos}.Radius;
        clearPos(iPos).r    = pos{iPos}.Center(1) - pos{iPos}.Radius;
        clearPos(iPos).b    = pos{iPos}.Center(2) + pos{iPos}.Radius;
        clearPos(iPos).l    = pos{iPos}.Center(1) + pos{iPos}.Radius;
    end
end

% Determine relative positioning and assign directions.
s_Above_d 	= clearPos(1).b < clearPos(2).t;
s_LeftOf_d 	= clearPos(1).r < clearPos(2).l;
s_RightOf_d = clearPos(1).l > clearPos(2).r;
s_Below_d   = clearPos(1).t > clearPos(2).b;

if s_Above_d && s_LeftOf_d
    sOClock = 3;
    dOClock = 12;
elseif s_Above_d && s_RightOf_d
    sOClock = 6;
    dOClock = 3;
elseif s_Below_d && s_RightOf_d
    sOClock = 9;
    dOClock = 6;
elseif s_Below_d && s_LeftOf_d
    sOClock = 12;
    dOClock = 9;
elseif s_Above_d
    sOClock = 6;
    dOClock = 12;
elseif s_LeftOf_d
    sOClock = 3;
    dOClock = 9;
elseif s_RightOf_d
    sOClock = 9;
    dOClock = 3;
elseif s_Below_d
    sOClock = 12;
    dOClock = 6;
else
    sOClock = 6;
    dOClock = 12;
end

transition.SourceOClock         = sOClock;
transition.DestinationOClock    = dOClock;

end
