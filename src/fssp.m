function varargout = fssp(varargin)
% FSSP - Firing Squad Synchronization Problem
%
% *Usage*
%   fssp(n) will solve the fssp problem using n finite state machines in 3n
%   steps.
%
%   fssp(n,t) will run the 3n solution to the fssp using n finite state
%   machines to time t. **defaults to 3n if not present or empty**
%
%   fssp(n,t,colorId) will run the fssp using n finite state machines to 
%   time t and will color the states according to the colorId.  
%
%   fssp(n,t,colorId,x0) will run the fssp using n finite state machines to 
%   time t will color the states according to the colorId from the initial 
%   condidition x0
%
% *Statement of the Problem*
% Consider a finite but arbitrary number of identical finite state machines
% (soldiers) arranged in a line. At time t = 0, each soldier is initialized
% to the quiescent (idle) state, except for the soldier on the far left
% (the Officer). The state of each soldier at each discrete time-step t > 0
% is dependent on its state and the state of its two neighbors at time
% t - 1 (except for the two soldiers at either end, each of whose state
% depends only on itself and its sole neighbor). In addition, if a soldier
% and its neighbors are in the quiescent state, then the soldier will
% remain quiescent at the next time-step. The problem is to define a finite
% set of states and state transition rules for the soldiers such that all
% soldiers enter a distinguished state (fire) at the same time and for the
% very first time.
%
% *References*
% http://en.wikipedia.org/wiki/Firing_squad_synchronization_problem
%
% *Authorship*
% Created by David Gross on 6 Aug 2011 at 5:13 PM
% Last Modified by David Gross 8 Aug 2011 at 7:46 AM
%
% *Revision Info*
% v0.001 - creation and proper simulation of 24 soldiers
% v0.002 - confirmed that it works for 2^k*3, k >=0
% v0.003 - add ReAnnouncer down the middle channel for n = 25
% v0.004 - change ReAnnouncer to Announcer down middle channel, confirmed
%          works for n = 25, 26, 27
% v0.005 - moving vectorized state definitions out of loop and into
%          subfunctions
% v0.006 - starting breaking large n ~= 2^k*3 cases in favor of buildling
%          the smaller blocks in order (n = 1, 2, 4, 5)
% v0.007 - adding generalStates to act as extra-important announcer in the
%          middle of odd splits
% v0.008 - stopped using general states and starting using announcer to act
%          as middle line.  now works for n = C*2^k for k = 1 ... \infty
%          and C \in {1 ... 9}
% v0.009 - solutions for 11 and 13 imply solution for 15 and C*2^k for k =
%          1 ... \infty and C \in { 1 ... 13 } 
% v0.010 - 17 => all solutions (since soldier-whisper is now as wide as
%          necessary for all reflection rules to be defined)
% v0.011 - remove generalStates, since they are unused in general (ha)
%          3n solution
% v0.012 - added colors for cross_stitch
%
% See Also
%   cross_stich

%% Color Sets
% standard colorset
% colors = 1:15;
% cross_stich colorsets
% solid colors
colors{1} = [01 02 06 07 08 09 10 11 12 13 14 15 03 04 05];
colors{2} = [06 07 01 02 03 04 05 11 12 13 14 15 08 09 10];
colors{3} = [11 12 06 07 08 09 10 01 02 03 04 05 13 14 15];
% switched echos
colors{4} = colors{1};  colors{4}([7 12]) = fliplr(colors{4}([7 12]));
colors{5} = colors{2};  colors{5}([7 12]) = fliplr(colors{5}([7 12]));
colors{6} = colors{3};  colors{6}([7 12]) = fliplr(colors{6}([7 12]));
% switch fourth officers
colors{7} = colors{4};  colors{7}([6 11]) = fliplr(colors{7}([6 11]));
colors{8} = colors{5};  colors{8}([6 11]) = fliplr(colors{8}([6 11]));
colors{9} = colors{6};  colors{9}([6 11]) = fliplr(colors{9}([6 11]));
% switch second officers
colors{10} = colors{7};  colors{10}([4 9]) = fliplr(colors{10}([4 9]));
colors{11} = colors{8};  colors{11}([4 9]) = fliplr(colors{11}([4 9]));
colors{12} = colors{9};  colors{12}([4 9]) = fliplr(colors{12}([4 9]));

%% Handle Inputs
if nargin >= 1, n = varargin{1}; else n = 24; end
if nargin >= 2 && ~isempty(varargin{2}), t = varargin{2}; else t = 3*n; end
if nargin >= 3, colorId = varargin{3}; else colorId = 1; end

%% Initialize States
[Idle, General, LeftFirstOfficer, LeftSecondOfficer, LeftThirdOfficer, ...
    LeftFourthOfficer, LeftEcho, RightFirstOfficer, RightSecondOfficer, ...
    RightThirdOfficer, RightFourthOfficer, RightEcho, Announcer, ...
    ReAnnouncer, Fire, idleStates, leftFirstOfficerStates, ...
    leftSecondOfficerStates, leftThirdOfficerStates, ...
    leftFourthOfficerStates, leftEchoStates, rightFirstOfficerStates, ...
    rightSecondOfficerStates, rightThirdOfficerStates, ...
    rightFourthOfficerStates, rightEchoStates, announcerStates, ...
    reAnnouncerStates, fireStates] = initializeStates(colors{colorId});

%% Handle Inputs after initialization
if nargin >= 4
    if isempty(varargin{4})
        x0 = Idle*ones(1,n); x0(end) = RightFirstOfficer;
    else
        x0 = varargin{4};
    end
else
    x0 = Idle*ones(1,n); x0(1) = LeftFirstOfficer;
end

%% Initialize Program
A = -Idle*ones(t,n+2);
A(:,1) = General;
A(:,end) = General;
A(1,2:end-1) = x0;

%% Run Program
for iTime = 2:t
    for iSoldier = 2:(n+1)
        rule = [...
            A(iTime-1,iSoldier-1), ...
            A(iTime-1,iSoldier), ...
            A(iTime-1,iSoldier+1)];
        isIdle = any(all(idleStates == ...
            repmat(rule,size(idleStates,1),1),2));
        if isIdle, A(iTime,iSoldier) = Idle; continue; end
        isLeftFirstOfficer = any(all(leftFirstOfficerStates == ...
            repmat(rule,size(leftFirstOfficerStates,1),1),2));
        if isLeftFirstOfficer, A(iTime,iSoldier) = LeftFirstOfficer; continue; end
        isLeftSecondOfficer = any(all(leftSecondOfficerStates == ...
            repmat(rule,size(leftSecondOfficerStates,1),1),2));
        if isLeftSecondOfficer, A(iTime,iSoldier) = LeftSecondOfficer; continue; end
        isLeftThirdOfficer = any(all(leftThirdOfficerStates == ...
            repmat(rule,size(leftThirdOfficerStates,1),1),2));
        if isLeftThirdOfficer, A(iTime,iSoldier) = LeftThirdOfficer; continue; end
        isLeftFourthOfficer = any(all(leftFourthOfficerStates == ...
            repmat(rule,size(leftFourthOfficerStates,1),1),2));
        if isLeftFourthOfficer, A(iTime,iSoldier) = LeftFourthOfficer; continue; end
        isLeftEcho = any(all(leftEchoStates == ...
            repmat(rule,size(leftEchoStates,1),1),2));
        if isLeftEcho, A(iTime,iSoldier) = LeftEcho; continue; end
        isRightFirstOfficer = any(all(rightFirstOfficerStates == ...
            repmat(rule,size(rightFirstOfficerStates,1),1),2));
        if isRightFirstOfficer, A(iTime,iSoldier) = RightFirstOfficer; continue; end
        isRightSecondOfficer = any(all(rightSecondOfficerStates == ...
            repmat(rule,size(rightSecondOfficerStates,1),1),2));
        if isRightSecondOfficer, A(iTime,iSoldier) = RightSecondOfficer; continue; end
        isRightThirdOfficer = any(all(rightThirdOfficerStates == ...
            repmat(rule,size(rightThirdOfficerStates,1),1),2));
        if isRightThirdOfficer, A(iTime,iSoldier) = RightThirdOfficer; continue; end
        isRightFourthOfficer = any(all(rightFourthOfficerStates == ...
            repmat(rule,size(rightFourthOfficerStates,1),1),2));
        if isRightFourthOfficer, A(iTime,iSoldier) = RightFourthOfficer; continue; end
        isRightEcho = any(all(rightEchoStates == ...
            repmat(rule,size(rightEchoStates,1),1),2));
        if isRightEcho, A(iTime,iSoldier) = RightEcho; continue; end
        isAnnouncer = any(all(announcerStates == ...
            repmat(rule,size(announcerStates,1),1),2));
        if isAnnouncer, A(iTime,iSoldier) = Announcer; continue; end
        isReAnnouncer = any(all(reAnnouncerStates == ...
            repmat(rule,size(reAnnouncerStates,1),1),2));
        if isReAnnouncer, A(iTime, iSoldier) = ReAnnouncer; continue; end
        isFire = any(all(fireStates == ...
            repmat(rule,size(fireStates,1),1),2));
        if isFire, A(iTime, iSoldier) = Fire; continue; end
    end
end

%% QA
A = check_solution(A,Fire);

%% Handle Outputs
if nargout > 0, refresh_plot(A); end
if nargout == 1, varargout{1} = A; end

end

%% Function to manage a clean plot of our program
function refresh_plot(A)
clf, imagesc(A); axis equal; axis tight; drawnow;
end

%% Function perform QA/Test on our solution
function A = check_solution(A,Fire)

isNotUsed = all(A(end,2:end-1) < 0);
while isNotUsed
    A(end,:) = [];
    isNotUsed = all(A(end,2:end-1) < 0);
end

if all(A(end,2:end-1)==Fire)
    if any(any(A(1:end-1,:) == Fire))
        disp('Someone fired early');
    else
        disp('Found a solution');
    end
else
    if any(any(A(1:end-1,:) == Fire))
        disp('Someone fired early');
    else
        disp('Not a solution');
    end
end

if size(A,1) > (size(A,2)-2)*3
    disp('Solution takes greater than t = 3n steps');
end

end

%% Function to initiazlie the rules for our state machine
function [Idle, General, LeftFirstOfficer, LeftSecondOfficer, LeftThirdOfficer, ...
    LeftFourthOfficer, LeftEcho, RightFirstOfficer, RightSecondOfficer, ...
    RightThirdOfficer, RightFourthOfficer, RightEcho, Announcer, ...
    ReAnnouncer, Fire, idleStates, leftFirstOfficerStates, ...
    leftSecondOfficerStates, leftThirdOfficerStates, ...
    leftFourthOfficerStates, leftEchoStates, rightFirstOfficerStates, ...
    rightSecondOfficerStates, rightThirdOfficerStates, ...
    rightFourthOfficerStates, rightEchoStates, announcerStates, ...
    reAnnouncerStates, fireStates] = initializeStates(stateValues)

Idle               = stateValues(01);
General            = stateValues(02);
LeftFirstOfficer   = stateValues(03);
LeftSecondOfficer  = stateValues(04);
LeftThirdOfficer   = stateValues(05);
LeftFourthOfficer  = stateValues(06);
LeftEcho           = stateValues(07);
RightFirstOfficer  = stateValues(08);
RightSecondOfficer = stateValues(09);
RightThirdOfficer  = stateValues(10);
RightFourthOfficer = stateValues(11);
RightEcho          = stateValues(12);
Announcer          = stateValues(13);
ReAnnouncer        = stateValues(14);
Fire               = stateValues(15);

idleStates = [ ...
    Idle Idle Idle ; ...
    Idle LeftFourthOfficer LeftFirstOfficer ; ...
    Idle Idle LeftSecondOfficer ; ...
    Idle Idle LeftThirdOfficer ; ...
    Idle Idle LeftFourthOfficer ; ...
    General LeftFourthOfficer LeftFirstOfficer ; ...
    General Idle LeftSecondOfficer ; ...
    General Idle LeftThirdOfficer ; ...
    General Idle LeftFourthOfficer ; ...
    General Idle Idle ; ...
    Idle Idle General ; ...
    LeftFirstOfficer LeftEcho Idle ; ...
    LeftEcho Idle Idle ; ...
    LeftFirstOfficer LeftEcho General ; ...
    LeftEcho Idle General ; ...
    RightFirstOfficer RightFourthOfficer Idle ; ...
    RightSecondOfficer Idle Idle ; ...
    RightThirdOfficer Idle Idle ; ...
    RightFourthOfficer Idle Idle ; ...
    RightFirstOfficer RightFourthOfficer General ; ...
    RightSecondOfficer Idle General ; ...
    RightThirdOfficer Idle General ; ...
    RightFourthOfficer Idle General ; ...
    Idle RightEcho RightFirstOfficer ; ...
    Idle Idle RightEcho ; ...
    General RightEcho RightFirstOfficer ; ...
    General Idle RightEcho ; ...
    RightFirstOfficer RightFourthOfficer LeftFourthOfficer ; ...
    RightFourthOfficer LeftFourthOfficer LeftFirstOfficer ; ...
    LeftFirstOfficer LeftEcho RightEcho ; ...
    LeftEcho RightEcho RightFirstOfficer ; ...
    RightFirstOfficer RightFourthOfficer Announcer ; ... n = 7
    Announcer LeftFourthOfficer LeftFirstOfficer ; ... n = 7
    RightSecondOfficer Idle ReAnnouncer ; ... n = 9
    ReAnnouncer Idle LeftSecondOfficer ; ... n = 9
    RightThirdOfficer Idle ReAnnouncer ; ... n = 9
    ReAnnouncer Idle LeftThirdOfficer ; ... n = 9
    RightFourthOfficer Idle ReAnnouncer ; ... n = 11
    ReAnnouncer Idle LeftFourthOfficer ; ... n = 11
    Idle Idle ReAnnouncer ; ... n = 11
    ReAnnouncer Idle Idle ; ... n = 11
    LeftFirstOfficer LeftEcho ReAnnouncer ; ... n = 13
    ReAnnouncer RightEcho RightFirstOfficer; ... n = 13
    LeftEcho Idle ReAnnouncer ; ... n = 17
    ReAnnouncer Idle RightEcho ; ... n = 17
    ];

leftFirstOfficerStates = [... n = 2^k*3
    LeftFirstOfficer Idle Idle ; ... n = 2^k*3
    LeftFirstOfficer LeftFirstOfficer Idle ; ... n = 2^k*3
    LeftFirstOfficer LeftFirstOfficer LeftFirstOfficer ; ... n = 2^k*3
    LeftSecondOfficer LeftFirstOfficer Idle ; ... n = 2^k*3
    LeftSecondOfficer LeftFirstOfficer LeftFirstOfficer ; ... n = 2^k*3
    LeftThirdOfficer LeftFirstOfficer LeftFirstOfficer ; ... n = 2^k*3
    LeftFirstOfficer Idle General ; ... n = 2^k*3
    LeftThirdOfficer LeftEcho Idle ; ... n = 2^k*3
    RightEcho RightThirdOfficer Idle ; ... n = 2^k*3
    Announcer Idle Idle ; ... n = 2^k*3
    Announcer Idle General ; ... n = 2^k*3
    RightEcho RightThirdOfficer General ; ... n = 2
    RightEcho RightThirdOfficer LeftThirdOfficer ; ... n = 4
    LeftThirdOfficer LeftEcho General ; ... n = 4
    RightEcho RightThirdOfficer Announcer ; ... n = 5
    Announcer Idle ReAnnouncer ; ... n = 7
    LeftThirdOfficer LeftEcho RightEcho ; ... n = 8
    LeftFirstOfficer Idle ReAnnouncer ; ... n = 9
    LeftThirdOfficer LeftEcho ReAnnouncer ; ... n = 9
    ];

leftSecondOfficerStates = [...
    General LeftFirstOfficer Idle ; ... n = 2^k*3
    LeftFourthOfficer LeftFirstOfficer LeftFirstOfficer ; ... n = 2^k*3
    RightFirstOfficer LeftFirstOfficer Idle ; ... n = 2^k*3
    ReAnnouncer LeftFirstOfficer Idle ; ... n = 5
    ];

leftThirdOfficerStates = [...
    General LeftSecondOfficer LeftFirstOfficer ; ... n = 2^k*3
    Idle LeftSecondOfficer LeftFirstOfficer ; ...  n = 2^k*3
    RightSecondOfficer LeftSecondOfficer LeftFirstOfficer ; ... n = 2^k*3
    ReAnnouncer LeftSecondOfficer LeftFirstOfficer ; ... n = 5
    ];

leftFourthOfficerStates = [...
    General LeftThirdOfficer LeftFirstOfficer ; ... n = 2^k*3
    Idle LeftThirdOfficer LeftFirstOfficer ; ... n = 2^k*3
    RightThirdOfficer LeftThirdOfficer LeftFirstOfficer ; ... n = 2^k*3
    Announcer LeftThirdOfficer LeftFirstOfficer ; ... n = 7
    ];

leftEchoStates = [...
    LeftFirstOfficer, LeftFirstOfficer, LeftEcho ; ... n = 2^k*3
    LeftSecondOfficer, LeftFirstOfficer, LeftEcho ; ... n = 2^k*3
    LeftThirdOfficer, LeftFirstOfficer, LeftEcho ; ... n = 2^k*3
    LeftFirstOfficer LeftFirstOfficer General ; ... n = 2^k*3
    LeftFirstOfficer LeftFirstOfficer RightFirstOfficer ; ... n = 2^k*3
    ReAnnouncer LeftFirstOfficer General ; ... n = 2^k*3
    ReAnnouncer LeftFirstOfficer RightFirstOfficer ; ... n = 2^k*3
    General LeftFirstOfficer General ; ... % n = 1
    LeftSecondOfficer LeftFirstOfficer General ; ... n = 4
    RightFirstOfficer LeftFirstOfficer RightFirstOfficer ; ... n = 4
    LeftSecondOfficer LeftFirstOfficer RightFirstOfficer ; ... n = 8
    LeftSecondOfficer LeftFirstOfficer ReAnnouncer ; ... n = 9
    LeftFirstOfficer LeftFirstOfficer ReAnnouncer ; ... n = 13
    ];

rightFirstOfficerStates = [...
    Idle Idle RightFirstOfficer ; ... n = 2^k*3
    Idle RightFirstOfficer RightFirstOfficer ; ... n = 2^k*3
    RightFirstOfficer RightFirstOfficer RightFirstOfficer ; ... n = 2^k*3
    Idle RightFirstOfficer RightSecondOfficer ; ... n = 2^k*3
    RightFirstOfficer RightFirstOfficer RightSecondOfficer ; ... n = 2^k*3
    RightFirstOfficer RightFirstOfficer RightThirdOfficer ; ... n = 2^k*3
    General Idle RightFirstOfficer ; ... n = 2^k*3
    Idle LeftThirdOfficer LeftEcho ; ... n = 2^k*3
    Idle RightEcho RightThirdOfficer ; ... n = 2^k*3
    General Idle Announcer ; ... n = 2^k*3
    Idle Idle Announcer ; ... n = 2^k*3
    General LeftThirdOfficer LeftEcho ; ... n = 2
    RightThirdOfficer LeftThirdOfficer LeftEcho ; ... n = 4
    General RightEcho RightThirdOfficer; ... n = 4
    Announcer LeftThirdOfficer LeftEcho ; ... n = 5
    ReAnnouncer Idle Announcer ; ... n = 7
    LeftEcho RightEcho RightThirdOfficer ; ... n = 8
    ReAnnouncer Idle RightFirstOfficer ; ... n = 9
    ReAnnouncer RightEcho RightThirdOfficer ; ... n = 9
    ];

rightSecondOfficerStates = [...
    Idle RightFirstOfficer General ; ... n = 2^k*3
    RightFirstOfficer RightFirstOfficer RightFourthOfficer ; ... n = 2^k*3
    Idle RightFirstOfficer LeftFirstOfficer ; ... n = 2^k*3
    Idle RightFirstOfficer ReAnnouncer ; ... n = 5
    ];

rightThirdOfficerStates = [...
    RightFirstOfficer RightSecondOfficer General ; ... n = 2^k*3
    RightFirstOfficer RightSecondOfficer Idle ; ... n = 2^k*3
    RightFirstOfficer RightSecondOfficer LeftSecondOfficer ; ... n = 2^k*3
    RightFirstOfficer RightSecondOfficer ReAnnouncer ; ... n = 5
    ];

rightFourthOfficerStates = [...
    RightFirstOfficer RightThirdOfficer General ; ... n = 2^k*3
    RightFirstOfficer RightThirdOfficer Idle ; ... n = 2^k*3
    RightFirstOfficer RightThirdOfficer LeftThirdOfficer ; ... n = 2^k*3
    RightFirstOfficer RightThirdOfficer Announcer ; ... n = 7
    ];

rightEchoStates = [...
    RightEcho RightFirstOfficer RightFirstOfficer ; ... n = 2^k*3
    RightEcho RightFirstOfficer RightSecondOfficer ; ... n = 2^k*3
    RightEcho RightFirstOfficer RightThirdOfficer ; ... n = 2^k*3
    General RightFirstOfficer RightFirstOfficer ; ... n = 2^k*3
    LeftFirstOfficer RightFirstOfficer RightFirstOfficer ; ... n = 2^k*3
    General RightFirstOfficer ReAnnouncer ; ... n = 2^k*3
    LeftFirstOfficer RightFirstOfficer ReAnnouncer ; ... n = 2^k*3
    General RightFirstOfficer General ; ... % n = 1
    General RightFirstOfficer RightSecondOfficer; ... n = 4
    LeftFirstOfficer RightFirstOfficer LeftFirstOfficer ; ... n = 4
    LeftFirstOfficer RightFirstOfficer RightSecondOfficer ; ... n = 8
    ReAnnouncer RightFirstOfficer RightSecondOfficer ; ... n = 9
    ReAnnouncer RightFirstOfficer RightFirstOfficer ; ... n = 13
    ];

announcerStates = [...
    RightEcho RightFirstOfficer RightFourthOfficer ; ... n = 2^k*3
    LeftFourthOfficer LeftFirstOfficer LeftEcho ; ... n = 2^k*3
    RightSecondOfficer ReAnnouncer LeftSecondOfficer ; ... n = 5 end of middle
    RightThirdOfficer Announcer LeftThirdOfficer ; ... n = 5 continue the middle
    LeftFirstOfficer Announcer RightFirstOfficer ; ... n = 5 continue the middle
    ReAnnouncer RightFirstOfficer ReAnnouncer ; ... n = 7
    ReAnnouncer LeftFirstOfficer ReAnnouncer ; ... n = 7
    ReAnnouncer RightFirstOfficer LeftFirstOfficer ; ... n = 9
    RightFirstOfficer LeftFirstOfficer ReAnnouncer ; ... n = 9
    ];

reAnnouncerStates = [...
    Idle Announcer Idle ; ... n = 2^k*3
    Idle ReAnnouncer Idle ; ... n = 2^k*3
    LeftEcho ReAnnouncer RightEcho ; ... n = 2^k*3
    RightFirstOfficer ReAnnouncer LeftFirstOfficer ; ... n = 2^k*3
    LeftFirstOfficer ReAnnouncer RightFirstOfficer ; ... n = 2^k*3
    General RightFirstOfficer LeftFirstOfficer ; ... n = 2
    RightFirstOfficer LeftFirstOfficer General ; ... n = 2
    RightFirstOfficer ReAnnouncer ReAnnouncer; ... n = 4
    ReAnnouncer ReAnnouncer LeftFirstOfficer ; ... n = 4
    Announcer RightFirstOfficer LeftFirstOfficer ; ... n = 5
    RightFirstOfficer LeftFirstOfficer Announcer ; ... n = 5
    RightFourthOfficer Announcer LeftFourthOfficer ; ... n = 7
    ];

fireStates = [...
    General RightEcho ReAnnouncer ; ... n = 2^k*3
    ReAnnouncer LeftEcho General ; ... n = 2^k*3
    RightEcho ReAnnouncer LeftEcho ; ... n = 2^k*3
    LeftEcho RightEcho ReAnnouncer ; ... n = 2^k*3
    ReAnnouncer LeftEcho RightEcho ; ... n = 2^k*3
    General LeftEcho General ; ... % n = 1
    General RightEcho General ; ... % n = 1
    General ReAnnouncer ReAnnouncer ; ... % n = 2
    ReAnnouncer ReAnnouncer General ; ... % n = 2
    RightEcho ReAnnouncer General ; ... n = 4
    General ReAnnouncer LeftEcho ; ... n = 4
    Announcer ReAnnouncer ReAnnouncer ; ... n = 5
    ReAnnouncer ReAnnouncer Announcer ; ... n = 5
    ReAnnouncer Announcer ReAnnouncer ; ... n = 5
    Announcer ReAnnouncer Announcer ; ... n = 7
    RightEcho ReAnnouncer Announcer ; ... n = 7
    Announcer ReAnnouncer LeftEcho ; ... n = 7
    LeftEcho RightEcho LeftEcho ; ... n = 8
    RightEcho LeftEcho RightEcho ; ... n = 8
    LeftEcho RightEcho Announcer ; ... n = 9
    RightEcho Announcer ReAnnouncer; ... n = 9
    ReAnnouncer Announcer LeftEcho ; ... n = 9
    Announcer LeftEcho RightEcho ; ... n = 9
    ];

allStates = [ ...
    idleStates; leftFirstOfficerStates; ...
    leftSecondOfficerStates; leftThirdOfficerStates; ...
    leftFourthOfficerStates; leftEchoStates; rightFirstOfficerStates; ...
    rightSecondOfficerStates; rightThirdOfficerStates; ...
    rightFourthOfficerStates; rightEchoStates; announcerStates; ...
    reAnnouncerStates; fireStates];

uniqueStates = unique(allStates,'rows');

if size(allStates,1) ~= size(uniqueStates,1)
    [~,usedStates] = unique(allStates,'rows');
    disp('Doubled States are:');
    allStates(~ismember(1:size(allStates,1),usedStates),:)
    keyboard
end

end