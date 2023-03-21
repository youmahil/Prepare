package cat.redmine.migration.domain;

import java.io.Serializable;

/**
* 설명 :
* 작성자 : 전길수
* 작성일 : 2023.1.16.
* 변경일 : 2023.1.16.
*/

public class Issue implements Serializable {
	// TODO : UID를 재 생성할 것.
	private static final long serialVersionUID = xxxx;
	
	private int id;
	private int trackerId;
	private int projectId;
	private String subject;
	private String description;
	private String dueDate;
	private int categoryId;
	private int statusId;
	private int assignedToId;
	private int priorityId;
	private int fixedVersionId;
	private int authorId;
	private int lockVersion;
	private String createdOn;
	private String updatedOn;
	private String startDate;
	private int doneRatio;
	private float estimatedHours;
	private int parentId;
	private int rootId;
	private int lft;
	private int rgt;
	private String isPrivate;
	private String closedOn;
	
	// TODO Getter와 Setter를 만들 것
}
