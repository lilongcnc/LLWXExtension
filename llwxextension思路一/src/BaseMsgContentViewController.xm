

%hook BaseMsgContentViewController

- (void)addMessageNode:(id)arg1 layout:(_Bool)arg2 addMoreMsg:(_Bool)arg3 { 
	%log;
	%orig;
}

- (void)tapAppNodeView:(id)arg1 {
	%log;
  	%orig; 
}

%end
