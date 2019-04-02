public class FMZ_PDFGeneratorController {
	public String content {get; set;}
    
    public PageReference prepPage(){
        return new PageReference('/apex/FMZ_PDFGenerator');
    }
}