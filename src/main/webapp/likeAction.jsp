<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="user.UserDAO"%>
<%@ page import="evaluation.EvaluationDAO"%>
<%@ page import="likey.LikeyDAO"%>
<%@ page import="java.io.PrintWriter"%>
<%!
	public static String getClientIP(HttpServletRequest request) {
		String ip = request.getHeader("X-FOWARDED-FOR");
		if (ip == null || ip.length() == 0) {
			ip = request.getHeader("Proxy-Client-IP");
		}
		if (ip == null || ip.length() == 0) {
			ip = request.getHeader("WL-Proxy-Client-IP");
		}if (ip == null || ip.length() == 0) {
			ip = request.getRemoteAddr();
		}
		return ip;		
	}
%>
<%
	String userID = null;
	if(session.getAttribute("userID") != null) {
		userID = (String) session.getAttribute("userID");
	}
	if(userID == null) {
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('로그인을 해주세요.');");
		script.println("location.href = 'userLogin.jsp'");
		script.println("</script>");
		script.close();
		return;
	}

	Integer evaluationID = null;
	request.setCharacterEncoding("UTF-8");
	if(request.getParameter("evaluationID") != null) {
		try {
			evaluationID = Integer.parseInt(request.getParameter("evaluationID"));
		} catch (Exception e) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('evaluationID 매개변수가 올바르지 않습니다.');");
			script.println("history.back();");
			script.println("</script>");
			script.close();
			return;
		}
	} else {
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('evaluationID 매개변수가 null입니다.');");
		script.println("history.back();");
		script.println("</script>");
		script.close();
		return;
	}

	String userIP = null;
	userIP = getClientIP(request);
	EvaluationDAO evaluationDAO = new EvaluationDAO();
	LikeyDAO likeyDAO = new LikeyDAO();
	if (evaluationDAO.getUserID(Integer.toString(evaluationID)).equals(userID)) {
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('자신이 쓴 글은 추천할 수 없습니다.');");
		script.println("history.back();");
		script.println("</script>");
		script.close();
		return;
	}
	int result = likeyDAO.like(userID, Integer.toString(evaluationID), userIP);
	if (result == 1) {
		result = evaluationDAO.like(Integer.toString(evaluationID));
		if(result == 1) {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('추천되었습니다.');");
			script.println("location.href = 'index.jsp'");
			script.println("</script>");
			script.close();
			return;
		} else {
			PrintWriter script = response.getWriter();
			script.println("<script>");
			script.println("alert('데이터베이스 오류가 발생했습니다.');");
			script.println("history.back();");
			script.println("</script>");
			script.close();
			return;
		}
	} else {
		PrintWriter script = response.getWriter();
		script.println("<script>");
		script.println("alert('한 게시글당 하나의 추천만 가능합니다.');");
		script.println("history.back();");
		script.println("</script>");
		script.close();
		return;
	}
%>