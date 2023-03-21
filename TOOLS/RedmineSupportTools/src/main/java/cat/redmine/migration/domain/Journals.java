package cat.redmine.migration.domain;

import java.io.Serializable;

/**
* 설명 :
* 작성자 : 전길수
* 작성일 : 2022.7.13.
* 변경일 : 2022.7.13.
*/

public class Journals implements Serializable {
	// TODO : UID를 재 생성할 것.
	private static final long serialVersionUID = xxxx;
	
	private int id;
	private int oldJournalId;
	private int journalizedId;
	private int oldJournalizedId;
	private String journalizedType;
	private String notes;
	private String userId;
	private String createdOn;
	private int privateNotes;
	
	// TODO: Getter와 Setter를 만들 것
}
