package cat.redmine.migration.domain;

import java.io.Serializable;

/**
* 설명 :
* 작성자 : 전길수
* 작성일 : 2022.7.13.
* 변경일 : 2022.7.13.
*/

public class JournalDetails implements Serializable {
	// TODO : UID를 재 생성할 것.
	private static final long serialVersionUID = xxxx;
	
	private int id;
	private int journalId;
	private String property;
	private String propKey;
	private String oldValue;
	private String value;
	
	// TODO: Getter와 Setter를 만들 것
}
