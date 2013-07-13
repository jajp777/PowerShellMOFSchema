## Generate MOF Schemas From PowerShell
PowerShell v4 let's you build [Custom Desired State Configuration Resources](http://technet.microsoft.com/en-us/library/dn249927.aspx)

One of the required components is MOF Schema File, for example.

	[version("1.0.0"), FriendlyName("Website")] 
	class Demo_IISWebsite : MSFT_BaseResourceConfiguration
	{
	  [Key] string Name;
	  [write] string PhysicalPath;
	  [write,ValueMap{"Present", "Absent"},Values{"Present", "Absent"}] string Ensure;
	  [write,ValueMap{"Started","Stopped"},Values{"Started", "Stopped"}] string State;
	  [write,ValueMap{"http", "https"},Values{"http", "https"}] string Protocol[];
	  [write] string BindingInfo[];
	  [write] string ApplicationPool;
	  [read] string ID;
	};
### That is too much typing for me
So I created a "DSL" in PowerShell to do it for me. This generates the above MOF Schema.

	New-MOFSchema WebSite {
	
	    Set-Version 1.0.1	
	    
		Add-ClassName Demo_IISWebsite
	
	    Add-Key string Name
	
	    Add-WriteProperty string PhysicalPath
	
	    Add-WriteValueMap "Present", "Absent" string Ensure
	    Add-WriteValueMap "Started", "Stopped" string State
	    Add-WriteValueMap "http", "https" string Protocol[]
	
	    Add-WriteProperty string BindingInfo[]
	    Add-WriteProperty string ApplicationPool
	
	    Add-ReadProperty string ID
	}

### Next
